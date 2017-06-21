#!/usr/bin/python

# system packages
import sys
import os
import argparse
import re

# external packages
import png  # package name is "pypng" on pypi.python.org


def slugify(s):
    """Simplifies ugly strings into something that can be used as an assembler
    label.

    >>> print slugify("[Some] _ Article's Title--")
    SOME_ARTICLES_TITLE

    From https://gist.github.com/dolph/3622892#file-slugify-py
    """

    # "[Some] _ Article's Title--"
    # "[SOME] _ ARTICLE'S TITLE--"
    s = s.upper()

    # "[SOME] _ ARTICLE'S_TITLE--"
    # "[SOME]___ARTICLE'S_TITLE__"
    for c in [' ', '-', '.', '/']:
        s = s.replace(c, '_')

    # "[SOME]___ARTICLE'S_TITLE__"
    # "SOME___ARTICLES_TITLE__"
    s = re.sub('\W', '', s)

    # "SOME___ARTICLES_TITLE__"
    # "SOME   ARTICLES TITLE  "
    s = s.replace('_', ' ')

    # "SOME   ARTICLES TITLE  "
    # "SOME ARTICLES TITLE "
    s = re.sub('\s+', ' ', s)

    # "SOME ARTICLES TITLE "
    # "SOME ARTICLES TITLE"
    s = s.strip()

    # "SOME ARTICLES TITLE"
    # "SOME_ARTICLES_TITLE"
    s = s.replace(' ', '_')

    return s


class AssemblerSyntax(object):
    def asm(self, text):
        return "\t%s" % text

    def comment(self, text):
        return "\t; %s" % text

    def label(self, text):
        return text

    def byte(self, text):
        return self.asm(".byte %s" % text)

    def word(self, text):
        return self.asm(".word %s" % text)

    def address(self, text):
        return self.asm(".addr %s" % text)

    def origin(self, text):
        return self.asm("*= %s" % text)

    def binary_constant(self, value):
        try:
            # already a string
            _ = len(value)
            return "#%%%s" % value
        except TypeError:
            return "#%s" % format(value, "08b")


class Mac65(AssemblerSyntax):
    def address(self, text):
        return self.asm(".word %s" % text)

    def binary_constant(self, value):
        # MAC/65 doesn't do binary constants
        try:
            # a string
            value = int(value, 2)
        except TypeError:
            pass
        return "#$%02x  ; %s" % (value, format(value, "08b"))


class CC65(AssemblerSyntax):
    def label(self, text):
        return "%s:" % text


class Listing(object):
    def __init__(self, assembler):
        self.assembler = assembler
        self.lines = []
        self.current = None
        self.desired_count = 1
        self.stash_list = []

    def __str__(self):
        self.flush_stash()
        return "\n".join(self.lines) + "\n"

    def out(self, line):
        self.flush_stash()
        self.lines.append(line)

    def out_append_last(self, line):
        self.lines[-1] += line

    def label(self, text):
        self.out(self.assembler.label(text))

    def comment(self, text):
        self.out_append_last(self.assembler.comment(text))

    def comment_line(self, text):
        self.out(self.assembler.comment(text))

    def asm(self, text):
        self.out(self.assembler.asm(text))

    def addr(self, text):
        self.out(self.assembler.address(text))

    def flush_stash(self):
        if self.current is not None and len(self.stash_list) > 0:
            self.lines.append(self.current(", ".join(self.stash_list)))
        self.current = None
        self.stash_list = []
        self.desired_count = 1

    def stash(self, desired, text, per_line):
        if self.current is not None and (self.current != desired or per_line == 1):
            self.flush_stash()
        if per_line > 1:
            if self.current is None:
                self.current = desired
                self.desired_count = per_line
            self.stash_list.append(text)
            if len(self.stash_list) >= self.desired_count:
                self.flush_stash()
        else:
            self.out(desired(text))

    def binary_constant(self, value):
        return self.assembler.binary_constant(value)

    def byte(self, text, per_line=1):
        self.stash(self.assembler.byte, text, per_line)

    def word(self, text, per_line=1):
        self.stash(self.assembler.word, text, per_line)


class Sprite(Listing):
    def __init__(self, pngfile, assembler, screen, xdraw=False, processor="any"):
        Listing.__init__(self, assembler)
        self.screen = screen

        reader = png.Reader(pngfile)
        try:
            pngdata = reader.asRGB8()
        except:
            raise RuntimeError

        self.xdraw = xdraw
        self.processor = processor
        self.niceName = slugify(os.path.splitext(pngfile)[0])
        self.width = pngdata[0]
        self.height = pngdata[1]
        self.pixelData = list(pngdata[2])
        self.jumpTable()
        for i in range(self.screen.numShifts):
            self.blitShift(i)

    def jumpTable(self):
        # Prologue
        self.label("%s" % self.niceName)
        self.comment("%d bytes per row" % self.screen.byteWidth(self.width))

        if self.processor == "any":
            self.out(".ifpC02")
            self.jump65C02()
            self.out(".else")
            self.jump6502()
            self.out(".endif")
        elif self.processor == "65C02":
            self.jump65C02()
        elif self.processor == "6502":
            self.jump6502()
        else:
            raise RuntimeError("Processor %s not supported" % self.processor)

    def save_axy_65C02(self):
        self.asm("pha")
        self.asm("phx")
        self.asm("phy")

    def restore_axy_65C02(self):
        self.asm("ply")
        self.asm("plx")
        self.asm("pla")

    def save_axy_6502(self):
        self.asm("pha")
        self.asm("txa")
        self.asm("pha")
        self.asm("tya")
        self.asm("pha")

    def restore_axy_6502(self):
        self.asm("pla")
        self.asm("tay")
        self.asm("pla")
        self.asm("tax")
        self.asm("pla")

    def jump65C02(self):
        self.save_axy_65C02()
        self.asm("ldy PARAM0")
        self.asm("ldx MOD%d_%d,y" % (self.screen.numShifts, self.screen.bitsPerPixel))

        self.asm("jmp (%s_JMP,x)\n" % (self.niceName))
        offset_suffix = ""
        
        # Bit-shift jump table for 65C02
        self.label("%s_JMP" % (self.niceName))
        for shift in range(self.screen.numShifts):
            self.addr("%s_SHIFT%d" % (self.niceName, shift))

    def jump6502(self):
        self.save_axy_6502()
        self.asm("ldy PARAM0")
        self.asm("ldx MOD%d_%d,y" % (self.screen.numShifts, self.screen.bitsPerPixel))

        # Fast jump table routine; faster and smaller than self-modifying code
        self.asm("lda %s_JMP+1,x" % (self.niceName))
        self.asm("pha")
        self.asm("lda %s_JMP,x" % (self.niceName))
        self.asm("pha")
        self.asm("rts\n")

        # Bit-shift jump table for generic 6502
        self.label("%s_JMP" % (self.niceName))
        for shift in range(self.screen.numShifts):
            self.addr("%s_SHIFT%d-1" % (self.niceName,shift))

    def blitShift(self, shift):
        # Blitting functions
        self.out("\n")
        
        # Track cycle count of the blitter. We start with fixed overhead:
        # SAVE_AXY + RESTORE_AXY + rts +    sprite jump table
        cycleCount = 9 + 12 + 6 +   3 + 4 + 6
    
        self.label("%s_SHIFT%d" % (self.niceName,shift))

        colorStreams = self.screen.byteStreamsFromPixels(shift, self)
        for c in colorStreams:
            self.comment_line(str(c))
        self.out("")
        maskStreams = self.screen.byteStreamsFromPixels(shift, self, True)

        self.asm("ldx PARAM1")
        cycleCount += 3
        rowStartCode,extraCycles = self.rowStartCalculatorCode();
        self.out(rowStartCode)
        cycleCount += extraCycles
        
        spriteChunks, cycleCount, optimizationCount = self.generateBlitter(colorStreams, maskStreams, cycleCount)
        
        for row in range(self.height):
            for chunkIndex in range(len(spriteChunks)):
                self.out(spriteChunks[chunkIndex][row])

        if self.processor == "any":
            self.out(".ifpC02")
            self.restore_axy_65C02()
            self.out(".else")
            self.restore_axy_6502()
            self.out(".endif")
        elif self.processor == "65C02":
            self.restore_axy_65C02()
        elif self.processor == "6502":
            self.restore_axy_6502()
        else:
            raise RuntimeError("Processor %s not supported" % self.processor)
        self.asm("rts")
        self.comment("Cycle count: %d, Optimized %d rows." % (cycleCount,optimizationCount))

    def generateBlitter(self, colorStreams, maskStreams, baseCycleCount):
        byteWidth = len(colorStreams[0])
        spriteChunks = [["" for y in range(self.height)] for x in range(byteWidth)]
        
        cycleCount = baseCycleCount
        optimizationCount = 0

        for row in range(self.height):
            
            byteSplits = colorStreams[row]
            
            # Generate blitting code
            for chunkIndex in range(len(byteSplits)):
                
                # Optimization
                if byteSplits[chunkIndex] != "00000000" and \
                    byteSplits[chunkIndex] != "10000000":
                
                    value = self.binary_constant(byteSplits[chunkIndex])

                    # Store byte into video memory
                    if self.xdraw:
                        spriteChunks[chunkIndex][row] = \
                        "\tlda (SCRATCH0),y\n" + \
                        "\teor %s\n" % value + \
                        "\tsta (SCRATCH0),y\n";
                        cycleCount += 5 + 2 + 6
                    else:
                        spriteChunks[chunkIndex][row] = \
                        "\tlda %s\n" % value + \
                        "\tsta (SCRATCH0),y\n";
                        cycleCount += 2 + 6
                else:
                    optimizationCount += 1
                
                # Increment indices
                if chunkIndex == len(byteSplits)-1:
                    spriteChunks[chunkIndex][row] += "\n"
                else:   
                    spriteChunks[chunkIndex][row] += "\tiny"
                    cycleCount += 2

            # Finish the row
            if row<self.height-1:
                rowStartCode, extraCycles = self.rowStartCalculatorCode()
                spriteChunks[chunkIndex][row] += "\tinx\n" + rowStartCode;
                cycleCount += 2 + extraCycles
                
        return spriteChunks, cycleCount, optimizationCount

    def rowStartCalculatorCode(self):
        return \
        "\tlda HGRROWS_H1,x\n" + \
        "\tsta SCRATCH1\n" + \
        "\tlda HGRROWS_L,x\n" + \
        "\tsta SCRATCH0\n" + \
        "\tldy PARAM0\n" + \
        "\tlda DIV%d_%d,y\n" % (self.screen.numShifts, self.screen.bitsPerPixel) + \
        "\ttay\n", 4 + 3 + 4 + 3 + 3 + 4 + 2;


def fillOutByte(numBits):
    filler = ""
    for bit in range(numBits):
        filler += "0"
    
    return filler


def shiftStringRight(string, shift, bitsPerPixel):
    if shift==0:
        return string
    
    shift *= bitsPerPixel
    result = ""
    
    for i in range(shift):
        result += "0"
        
    result += string
    return result
                


class ScreenFormat(object):
    numShifts = 8

    bitsPerPixel = 1

    screenWidth = 320

    screenHeight = 192

    def __init__(self):
        self.offsets = self.generate_row_offsets()
        self.numX = self.screenWidth / self.bitsPerPixel

    def byteWidth(self, png_width):
        return (png_width * self.bitsPerPixel + self.numShifts - 1) // self.numShifts + 1

    def bitsForColor(self, pixel):
        raise NotImplementedError

    def bitsForMask(self, pixel):
        raise NotImplementedError

    def pixelColor(self, pixelData, row, col):
        raise NotImplementedError

    def generate_row_offsets(self):
        offsets = [40 * y for y in range(self.screenHeight)]
        return offsets

    def generate_row_addresses(self, baseAddr):
        addrs = [baseAddr + offset for offset in self.offsets]
        return addrs


class HGR(ScreenFormat):
    numShifts = 7

    bitsPerPixel = 2

    screenWidth = 280

    black,magenta,green,orange,blue,white,key = range(7)

    def bitsForColor(self, pixel):
        if pixel == self.black:
            return "00"
        else:
            if pixel == self.white:
                return "11"
            else:
                if pixel == self.green or pixel == self.orange:
                    return "01"

        # blue or magenta
        return "10"

    def bitsForMask(self, pixel):
        if pixel == self.black:
            return "00"

        return "11"

    def highBitForColor(self, pixel):
        # Note that we prefer high-bit white because blue fringe is less noticeable than magenta.
        highBit = "0"
        if pixel == self.orange or pixel == self.blue or pixel == self.white:
            highBit = "1"

        return highBit

    def highBitForMask(self, pixel):
        return "1"

    def pixelColor(self, pixelData, row, col):
        r = pixelData[row][col*3]
        g = pixelData[row][col*3+1]
        b = pixelData[row][col*3+2]
        color = self.black
        
        if r==255 and g==0 and b==255:
            color = self.magenta
        else:
            if r==0 and g==255 and b==0:
                color = self.green
            else:
                if r==0 and g==0 and b==255:
                    color = self.blue
                else:
                    if r==255 and g>0 and b==0:
                        color = self.orange
                    else:
                        if r==255 and g==255 and b==255:
                            color = self.white
                        else:
                            if r==g and r==b and r!=0 and r!=255:   # Any gray is chroma key
                                color = self.key
        return color

    def byteStreamsFromPixels(self, shift, source, mask=False):
        byteStreams = ["" for x in range(source.height)]
        byteWidth = self.byteWidth(source.width)

        if mask:
            bitDelegate = self.bitsForMask
            highBitDelegate = self.highBitForMask
        else:
            bitDelegate = self.bitsForColor
            highBitDelegate = self.highBitForColor

        for row in range(source.height):
            bitStream = ""
            
            # Compute raw bitstream for row from PNG pixels
            for pixelIndex in range(source.width):
                pixel = self.pixelColor(source.pixelData,row,pixelIndex)
                bitStream += bitDelegate(pixel)
            
            # Shift bit stream as needed
            bitStream = shiftStringRight(bitStream, shift, self.bitsPerPixel)
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
                highBit = highBitDelegate(source.pixelData[row][0])
                
                byteSplits[byteIndex] = highBit + bitChunk
                bitPos += 7
                
                byteStreams[row] = byteSplits;

        return byteStreams

    def generate_row_offsets(self):
        offsets = []
        for y in range(self.screenHeight):
            # From Apple Graphics and Arcade Game Design
            a = y // 64
            d = y - (64 * a)
            b = d // 8
            c = d - 8 * b
            offsets.append((1024 * c) + (128 * b) + (40 * a))
        return offsets


class HGRBW(HGR):
    bitsPerPixel = 1

    def bitsForColor(self, pixel):
        if pixel == self.white:
            return "1"
        else:
            return "0"

    def bitsForMask(self, pixel):
        if pixel == self.key:
            return "0"
        return "1"

    def pixelColor(self, pixelData, row, col):
        r = pixelData[row][col*3]
        g = pixelData[row][col*3+1]
        b = pixelData[row][col*3+2]
        color = self.black
        
        if r==255 and g==255 and b==255:
            color = self.white
        elif r==g and r==b and r!=0 and r!=255:   # Any gray is chroma key
            color = self.key
        else:
            color = self.black
        return color


class RowLookup(Listing):
    def __init__(self, assembler, screen):
        Listing.__init__(self, assembler)
        self.generate_y(screen)

    def generate_y(self, screen):
        self.label("HGRROWS_H1")
        for addr in screen.generate_row_addresses(0x2000):
            self.byte("$%02x" % (addr // 256), 8)

        self.out("\n")
        self.label("HGRROWS_H2")
        for addr in screen.generate_row_addresses(0x4000):
            self.byte("$%02x" % (addr // 256), 8)

        self.out("\n")
        self.label("HGRROWS_L")
        for addr in screen.generate_row_addresses(0x2000):
            self.byte("$%02x" % (addr & 0xff), 8)


class ColLookup(Listing):
    def __init__(self, assembler, screen):
        Listing.__init__(self, assembler)
        self.generate_x(screen)

    def generate_x(self, screen):
        self.out("\n")
        self.label("DIV%d_%d" % (screen.numShifts, screen.bitsPerPixel))
        for pixel in range(screen.numX):
            self.byte("$%02x" % ((pixel / screen.numShifts) * screen.bitsPerPixel), screen.numShifts)

        self.out("\n")
        self.label("MOD%d_%d" % (screen.numShifts, screen.bitsPerPixel))
        for pixel in range(screen.numX):
            self.byte("$%02x" % ((pixel % screen.numShifts) * screen.bitsPerPixel), screen.numShifts)


if __name__ == "__main__":
    disclaimer = '''
; This file was generated by HiSprite.py, a sprite compiler by Quinn Dunki.
; If you feel the need to modify this file, you are probably doing it wrong.
'''

    parser = argparse.ArgumentParser(description="Sprite compiler for 65C02/6502 to generate assembly code to render all shifts of the given sprite, optionally with exclusive-or drawing (if background will be non-black). Generated code has conditional compilation directives for the CC65 assembler to allow the same file to be compiled for either architecture.")
    parser.add_argument("-v", "--verbose", default=0, action="count")
    parser.add_argument("-c", "--cols", action="store_true", default=False, help="output column (x position) lookup tables")
    parser.add_argument("-r", "--rows", action="store_true", default=False, help="output row (y position) lookup tables")
    parser.add_argument("-x", "--xdraw", action="store_true", default=False, help="use XOR for sprite drawing")
    parser.add_argument("-a", "--assembler", default="cc65", choices=["cc65","mac65"], help="Assembler syntax (default: %(default)s)")
    parser.add_argument("-p", "--processor", default="any", choices=["any","6502", "65C02"], help="Processor type (default: %(default)s)")
    parser.add_argument("-s", "--screen", default="hgrcolor", choices=["hgrcolor","hgrbw"], help="Screen format (default: %(default)s)")
    parser.add_argument("files", metavar="IMAGE", nargs="*", help="a PNG image [or a list of them]. PNG files must not have an alpha channel!")
    options, extra_args = parser.parse_known_args()

    if options.assembler.lower() == "cc65":
        assembler = CC65()
    elif options.assembler.lower() == "mac65":
        assembler = Mac65()
    else:
        print("Unknown assembler %s" % options.assembler)
        parser.print_help()
        exit(1)

    if options.screen.lower() == "hgrcolor":
        screen = HGR()
    elif options.screen.lower() == "hgrbw":
        screen = HGRBW()
    else:
        print("Unknown screen format %s" % options.screen)
        parser.print_help()
        exit(1)

    listings = []

    for pngfile in options.files:
        try:
            listings.append(Sprite(pngfile, assembler, screen, options.xdraw, options.processor))
        except RuntimeError, e:
            print e
            parser.print_help()

    if options.rows:
        listings.append(RowLookup(assembler, screen))

    if options.cols:
        listings.append(ColLookup(assembler, screen))

    if listings:
        print disclaimer

        for section in listings:
            print section
