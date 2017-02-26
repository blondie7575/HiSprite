#!/usr/bin/python

import sys,os,png

class Colors:
	black,magenta,green,orange,blue,white,key = range(7)



def main(argv):
	
	if len(argv)<1:
		usage()
		exit(0)

	if sys.argv[1] == "--tables":
		printHorizontalLookup()
		exit(0)

	pngfile = sys.argv[1]
	xdraw = 0
	if len(argv)>1 and sys.argv[2] == "--xdraw":
		xdraw = 1

	reader = png.Reader(pngfile)
	try:
		pngdata = reader.asRGB8()
	except:
		usage()

	width = pngdata[0]
	height = pngdata[1]
	pixelData = pngdata[2]	
	byteWidth = width/2+1+1	 # TODO: Calculate a power of two for this
	niceName = os.path.splitext(pngfile)[0].upper()
	
	disclaimer()
	
	# Prologue
	print "%s: ;%d bytes per row" % (niceName,byteWidth)	
	print "\tSAVE_AXY"
	print "\tldy PARAM0"
	print "\tldx MOD7_2,y"
	print "\tjmp (%s_JMP,x)\n" % (niceName)
	
	# Bit-shift jump table
	print "%s_JMP:" % (niceName)	
	for shift in range(0,7):
		print "\t.addr %s_SHIFT%d" % (niceName,shift)

	# Blitting functions
	print "\n"
	for shift in range(0,7):
		print "%s_SHIFT%d:" % (niceName,shift)
		print "\tldx PARAM1"
		print rowStartCalculatorCode();

		spriteChunks = layoutSpriteChunk(pixelData,width,height,shift,xdraw)
		
		for row in range(height):
			for chunkIndex in range(len(spriteChunks)):
				print spriteChunks[chunkIndex][row]
			
		print "\n"				


def layoutSpriteChunk(pixelData,width,height,shift,xdraw):

	colorStreams = byteStreamsFromPixels(pixelData,width,height,shift,bitsForColor,highBitForColor)
	maskStreams = byteStreamsFromPixels(pixelData,width,height,shift,bitsForMask,highBitForMask)
	code = generateBlitter(colorStreams,maskStreams,height,xdraw)

	return code


def byteStreamsFromPixels(pixelData,width,height,shift,bitDelegate,highBitDelegate):

	byteStreams = ["" for x in range(height)]
	byteWidth = width/2+1+1

	for row in range(height):
		bitStream = ""
		
		# Compute raw bitstream for row from PNG pixels
		for pixelIndex in range(width):
			pixel = pixelColor(pixelData,row,pixelIndex)
			bitStream += bitDelegate(pixel)
		
		# Shift bit stream as needed
		bitStream = shiftStringRight(bitStream,shift)
		bitStream = bitStream[:byteWidth*8]
		
		# Split bitstream into bytes
		bitPos = 0
		byteSplits = [0 for x in range(byteWidth)]
		
		for byteIndex in range(byteWidth):
			remainingBits = len(bitStream) - bitPos
				
			bitChunk = ""
			
			if remainingBits < 0:
				bitChunk = "0000000"
			else:	
				if remainingBits < 7:
					bitChunk = bitStream[bitPos:]
					bitChunk += fillOutByte(7-remainingBits)
				else:	
					bitChunk = bitStream[bitPos:bitPos+7]				
			
			bitChunk = bitChunk[::-1]
			
			# Determine palette bit from first pixel on each row
			highBit = highBitDelegate(pixelData[row][0])
			
			byteSplits[byteIndex] = highBit + bitChunk
			bitPos += 7
			
			byteStreams[row] = byteSplits;

	return byteStreams


def generateBlitter(colorStreams,maskStreams,height,xdraw):
	
	byteWidth = len(colorStreams[0])
	spriteChunks = [["" for y in range(height)] for x in range(byteWidth)]
	
	for row in range(height):
		
		byteSplits = colorStreams[row]
		
		# Generate blitting code
		for chunkIndex in range(len(byteSplits)):
			
			# Store byte into video memory
			if xdraw:
				spriteChunks[chunkIndex][row] = \
				"\tlda (SCRATCH0),y\n" + \
				"\teor #%%%s\n" % byteSplits[chunkIndex] + \
				"\tsta (SCRATCH0),y\n";
			else:
				spriteChunks[chunkIndex][row] = \
				"\tlda #%%%s\n" % byteSplits[chunkIndex] + \
				"\tsta (SCRATCH0),y\n";

			# Increment indices
			if chunkIndex == len(byteSplits)-1:
				spriteChunks[chunkIndex][row] += "\n"
			else:	
				spriteChunks[chunkIndex][row] += "\tiny"

		# Finish the row
		if row<height-1:
			spriteChunks[chunkIndex][row] += "\tinx\n" + rowStartCalculatorCode();
		else:
			spriteChunks[chunkIndex][row] += "\tRESTORE_AXY\n"
			spriteChunks[chunkIndex][row] += "\trts\n"
			
	return spriteChunks
				

def rowStartCalculatorCode():
	return \
	"\tlda HGRROWS_H1,x\n" + \
	"\tsta SCRATCH1\n" + \
	"\tlda HGRROWS_L,x\n" + \
	"\tsta SCRATCH0\n" + \
	"\tldy PARAM0\n" + \
	"\tlda DIV7_2,y\n" + \
	"\ttay\n";		


def fillOutByte(numBits):
	filler = ""
	for bit in range(numBits):
		filler += "0"
	
	return filler


def shiftStringRight(string,shift):
	if shift==0:
		return string
	
	shift *=2	
	result = ""
	
	for i in range(shift):
		result += "0"
		
	result += string
	return result
				

def bitsForColor(pixel):

	if pixel == Colors.black:
		return "00"
	else:
		if pixel == Colors.white:
			return "11"
		else:
			if pixel == Colors.green or pixel == Colors.orange:
				return "01"

	# blue or magenta
	return "10"


def bitsForMask(pixel):

	if pixel == Colors.black:
		return "00"

	return "11"


def highBitForColor(pixel):

	# Note that we prefer high-bit white because blue fringe is less noticeable than magenta.
	highBit = "0"
	if pixel == Colors.orange or pixel == Colors.blue or pixel == Colors.white:
		highBit = "1"

	return highBit


def highBitForMask(pixel):

	return "1"


def pixelColor(pixelData,row,col):
	r = pixelData[row][col*3]
	g = pixelData[row][col*3+1]
	b = pixelData[row][col*3+2]
	color = Colors.black
	
	if r==255 and g==0 and b==255:
		color = Colors.magenta
	else:
		if r==0 and g==255 and b==0:
			color = Colors.green
		else:
			if r==0 and g==0 and b==255:
				color = Colors.blue
			else:
				if r==255 and g>0 and b==0:
					color = Colors.orange
				else:
					if r==255 and g==255 and b==255:
						color = Colors.white
					else:
						if r==g and r==b and r!=0 and r!=255:	# Any gray is chroma key
							color = Colors.key
	return color
	

def printHorizontalLookup():
	disclaimer()
	
	print "DIV7_2:"
	for pixel in range(140):
		print "\t.byte $%02x" % ((pixel / 7)*2)

	print "\n\nMOD7_2:"
	for pixel in range(140):
		print "\t.byte $%02x" % ((pixel % 7)*2)
		
		
def usage():
	print '''
Usages: 
	HiSprite <png file> [--xdraw]
		Generates 6502 assembly to render all shifts of the given sprite,
		optionally with exclusive-or drawing (if background will be non-black)
		
	HiSprite --tables
		Generates lookup tables for horizontal sprite shifts (division and modulus 7)
		
PNG file must not have an alpha channel!
'''
	sys.exit(2)
	

def disclaimer():
	print '''
; This file was generated by HiSprite.py, a sprite compiler by Quinn Dunki.
; If you feel the need to modify this file, you are probably doing it wrong.
'''
	return


if __name__ == "__main__":
	main(sys.argv[1:])
	
