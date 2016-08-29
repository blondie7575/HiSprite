#!/usr/bin/python

import sys,os,png

class Colors:
	black,magenta,green = range(3)



def main(argv):
	
	if len(argv)<1:
		printHorzontalLookup()
		exit(0)

	pngfile = sys.argv[1]

	reader = png.Reader(pngfile)
	try:
		pngdata = reader.asRGB8()
	except:
		usage()

	width = pngdata[0]
	height = pngdata[1]
	pixeldata = pngdata[2]	
	byteWidth = width/2+1+1	 # TODO: Calculate a power of two for this
	
	for shift in range(0,7):
		print "%s_SHIFT%d: ;%d bytes per row" % (os.path.splitext(pngfile)[0].upper(),shift,byteWidth)
		
		spriteChunks = layoutSpriteChunk(pixeldata,width,height,shift)
		
		for row in range(height):
			for chunkIndex in range(len(spriteChunks)):
				print spriteChunks[chunkIndex][row]
			
		print "\n"				
			
		
	

def layoutSpriteChunk(pixeldata,width,height,shift):

	bitmap = [[0 for x in range(width)] for y in range(height)]
	
	byteWidth = width/2+1+1	 # TODO: Calculate a power of two for this
	spriteChunks = [["" for y in range(height)] for x in range(byteWidth)]

	for row in range(height):
		pixelRow = bitmap[row]
		bitStream = ""
		
		for pixelIndex in range(width):
			pixel = pixelColor(pixeldata,row,pixelIndex)
			if pixel == Colors.black:
				bitStream += "00"
			else:
				if pixel == Colors.green:
					bitStream += "01"
				else:
					bitStream += "10"
		
		bitStream = shiftStringRight(bitStream,shift)
		bitStream = bitStream[:byteWidth*8]
				
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
				
			byteSplits[byteIndex] = "0" + bitChunk
			bitPos += 7
				
		for chunkIndex in range(len(byteSplits)):
			spriteChunks[chunkIndex][row] = ".byte %%%s" % byteSplits[chunkIndex]
	
	return spriteChunks
				
			
			
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
				
				
def pixelColor(pixeldata,row,col):
	r = pixeldata[row][col*3]
	g = pixeldata[row][col*3+1]
	b = pixeldata[row][col*3+2]
	color = Colors.black
	
	if r==255 and g==0 and b==255:
		color = Colors.magenta
	else:
		if r==0 and g==255 and b==0:
			color = Colors.green

	return color
	

def printHorzontalLookup():
	print "HGRROWS_GRN:"
	for byte in range(40):
		pixels = 4
		offset = 0
		if (byte%2):
			pixels = 3
			offset = -1
			
		for entry in range(pixels):
			print "\t.byte $%02x" % (byte + offset)

	print "\nHGRROWS_BITSHIFT_GRN:"
	for pixel in range(140):
		print "\t.byte $%02x" % ((pixel % 7)*32) # 32 = 4 shifts of 8 bytes
		
		
def usage():
	print '''
Usage: HiSprite <png file>

PNG file must not have an alpha channel!
'''
	sys.exit(2)
	
	
if __name__ == "__main__":
	main(sys.argv[1:])
	