#!/usr/bin/python

import sys,os,png

class Colors:
	black,magenta,green = range(3)
	
	
def main(argv):
	
	if len(argv)<1:
		usage()

	pngfile = sys.argv[1]

	reader = png.Reader(pngfile)
	try:
		pngdata = reader.asRGB8()
	except:
		usage()

	width = pngdata[0];
	height = pngdata[1];
	pixeldata = pngdata[2];
	
	bitmap = [[0 for x in range(width)] for y in range(height)] 		
	
	for shift in range(7):
		for phase in range(2):
				
			for row in range(height):
				for col in range(width):
					(color,half) = pixelRemap(pixeldata,row,col,width,shift,phase)
					bitmap[row][col] = color
			
			spriteNum = shift*2+phase
			printBitmap(bitmap,os.path.splitext(pngfile)[0].upper(),spriteNum,half,0,phase)						

	

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
	

def pixelRemap(pixeldata,row,col,width,shift,phase):
	halfPixel = 0
	overHalf = 0

	origColor = pixelColor(pixeldata,row,col)
	
	if shift>=width:
		overHalf = 1
		shift = shift-width+1
		if phase==0:
			halfPixel = 1
		
	if phase==0:
		col = col+shift
	else:
		col = col-(width-shift)
		if origColor==Colors.green:
			col = col+1
		if not overHalf:
			halfPixel = -1
					
	if col >= width or col<0:
		return (Colors.black,halfPixel)
	
	remapColor = pixelColor(pixeldata,row,col)
	return (remapColor,halfPixel)
	
			
def colorString(color,currByteString):
	if color==Colors.magenta:
		return 'ba'
	else:
		if color==Colors.green:
			return 'ab'
	
	return '00'
	

def containsGreen(row):
	for col in range(len(row)):
		if row[col] == Colors.green:
			return 1
			
	return 0
	
				
def printBitmap(bitmap,label,spriteNum,halfShift,highbit,phase):
	print "%s%d:" % (label,spriteNum)
	for row in range(len(bitmap)):
		byteString = ""
		 
		for col in range(len(bitmap[0])):
			append = colorString(bitmap[row][col],byteString)
			byteString += append
		
		if halfShift>0:
			byteString = "0" + byteString[:-1]
		else:
			if halfShift<0:
				byteString = byteString[1:] + "0"
		
		if len(byteString)>6:
			byteString = byteString[:-1]
		
#		if phase==0:
#			byteString = byteString[::-1]
				
		sys.stdout.write("\t.byte\t%%%d%s\n" % (highbit,byteString));

	sys.stdout.write('\n\n')			
	sys.stdout.flush()
			
		
			
def usage():
	print '''
Usage: HiSprite <png file>

PNG file must not have an alpha channel!
'''
	sys.exit(2)




if __name__ == "__main__":
	main(sys.argv[1:])