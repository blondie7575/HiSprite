#!/usr/bin/python

import sys,os,png

class Colors:
	black,magenta = range(2)
	
	
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
			if shift==0 and phase>0:
				continue
				
			for row in range(height):
				for col in range(width):
					(pixelr,pixelg,pixelb,half) = pixelRemap(pixeldata,row,col,width,shift,phase)
			
					if pixelr==255 and pixelg==0 and pixelb==255:
						bitmap[row][col] = Colors.magenta
					else:
						bitmap[row][col] = Colors.black
			
			spriteNum = max(0,shift*2-1+phase)
			printBitmap(bitmap,os.path.splitext(pngfile)[0].upper(),spriteNum,half,0)						

	

def pixelRemap(pixeldata,row,col,width,shift,phase):
	halfPixel = 0
	overHalf = 0
	
	if shift>=width:
		overHalf = 1
		shift = shift-width+1
		if phase==0:
			halfPixel = 1
		
	if phase==0:
		col = col+shift
	else:
		col = col-(width-shift)
		if not overHalf:
			halfPixel = -1

					
	if col >= width or col<0:
		return (0,0,0,halfPixel)
		
	r = pixeldata[row][col*3]
	g = pixeldata[row][col*3+1]
	b = pixeldata[row][col*3+2]
			
	return (r,g,b,halfPixel)
	
			
def colorString(color,currByteString):
	if len(currByteString) > 6:
		if color==Colors.magenta:
			return '1'
		else:
			return '0'
	else:	
		if color==Colors.magenta:
			return '10'
	
	return '00'
	
		
def printBitmap(bitmap,label,shift,halfShift,highbit):
	print "%s%d:" % (label,shift)
	for row in range(len(bitmap)):
		byteString = "%d" % highbit
		 
		for col in range(len(bitmap[0])):
			append = colorString(bitmap[row][col],byteString)
			byteString += append
		
		if halfShift>0:
			byteString = "0" + byteString[:-1]
		else:
			if halfShift<0:
				byteString = byteString[1:] + "0"
			
		sys.stdout.write("\t.byte\t%%%s\n" % byteString);

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