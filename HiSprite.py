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
    extension = "s"
    comment_char = ";"

    def asm(self, text):
        return "\t%s" % text

    def comment(self, text):
        return "\t%s %s" % (self.comment_char, text)

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

    def include(self, text):
        return self.asm(".include \"%s\"" % text)

    def binary_constant(self, value):
        try:
            # already a string
            _ = len(value)
            return "#%%%s" % value
        except TypeError:
            return "#%%%s" % format(value, "08b")


class Mac65(AssemblerSyntax):
    def address(self, text):
        return self.asm(".word %s" % text)

    def binary_constant(self, value):
        try:
            # a string
            value = int(value, 2)
        except TypeError:
            pass
        return "#~%s" % format(value, "08b")


class CC65(AssemblerSyntax):
    extension = "s"

    def label(self, text):
        return "%s:" % text


class Listing(object):
    def __init__(self, assembler):
        self.assembler = assembler
        self.lines = []
        self.current = None
        self.desired_count = 1
        self.stash_list = []
        self.slug = "sprite-driver"

    def __str__(self):
        self.flush_stash()
        return "\n".join(self.lines) + "\n"

    def add_listing(self, other):
        self.lines.extend(other.lines)

    def get_filename(self, basename):
        return "%s-%s.%s" % (basename, self.slug.lower(), self.assembler.extension)

    def write(self, basename, disclaimer):
        filename = self.get_filename(basename)
        print("Writing to %s" % filename)
        with open(filename, "w") as fh:
            fh.write(disclaimer + "\n\n")
            fh.write(str(self))
        return filename

    def out(self, line=""):
        self.flush_stash()
        self.lines.append(line)

    def out_append_last(self, line):
        self.lines[-1] += line

    def pop_asm(self, cmd=""):
        self.flush_stash()
        if cmd:
            search = self.assembler.asm(cmd)
            i = -1
            while self.lines[i].strip().startswith(self.assembler.comment_char):
                i -= 1
            if self.lines[i] == search:
                self.lines.pop(i)
        else:
            self.lines.pop(-1)

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

    def include(self, text):
        self.out(self.assembler.include(text))

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
    backing_store_sizes = set()

    def __init__(self, pngfile, assembler, screen, xdraw=False, use_mask=False, backing_store=False, clobber=False, processor="any", name=""):
        Listing.__init__(self, assembler)
        self.screen = screen

        reader = png.Reader(pngfile)
        pngdata = reader.asRGB8()

        self.xdraw = xdraw
        self.use_mask = use_mask
        self.backing_store = backing_store
        self.clobber = clobber
        self.processor = processor
        if not name:
            name = os.path.splitext(pngfile)[0]
        self.slug = slugify(name)
        self.width = pngdata[0]
        self.height = pngdata[1]
        self.pixelData = list(pngdata[2])
        self.jumpTable()
        for i in range(self.screen.numShifts):
            self.blitShift(i)

    def jumpTable(self):
        # Prologue
        self.label("%s" % self.slug)
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
        if not self.clobber:
            self.save_axy_65C02()
        self.asm("ldy PARAM0")
        self.asm("ldx MOD%d_%d,y" % (self.screen.numShifts, self.screen.bitsPerPixel))

        self.asm("jmp (%s_JMP,x)\n" % (self.slug))
        offset_suffix = ""
        
        # Bit-shift jump table for 65C02
        self.label("%s_JMP" % (self.slug))
        for shift in range(self.screen.numShifts):
            self.addr("%s_SHIFT%d" % (self.slug, shift))

    def jump6502(self):
        if not self.clobber:
            self.save_axy_6502()
        self.asm("ldy PARAM0")
        self.asm("ldx MOD%d_%d,y" % (self.screen.numShifts, self.screen.bitsPerPixel))

        # Fast jump table routine; faster and smaller than self-modifying code
        self.asm("lda %s_JMP+1,x" % (self.slug))
        self.asm("pha")
        self.asm("lda %s_JMP,x" % (self.slug))
        self.asm("pha")
        self.asm("rts\n")

        # Bit-shift jump table for generic 6502
        self.label("%s_JMP" % (self.slug))
        for shift in range(self.screen.numShifts):
            self.addr("%s_SHIFT%d-1" % (self.slug,shift))

    def blitShift(self, shift):
        # Blitting functions
        self.out("\n")
        
        # Track cycle count of the blitter. We start with fixed overhead:
        # SAVE_AXY + RESTORE_AXY + rts +    sprite jump table
        cycleCount = 9 + 12 + 6 +   3 + 4 + 6
    
        self.label("%s_SHIFT%d" % (self.slug,shift))

        colorStreams = self.screen.byteStreamsFromPixels(shift, self)
        maskStreams = self.screen.byteStreamsFromPixels(shift, self, True)
        for c, m in zip(colorStreams, maskStreams):
            self.comment_line(str(c) + "  " + str(m))
        self.out("")

        if self.backing_store:
            byteWidth = len(colorStreams[0])
            self.asm("jsr savebg_%dx%d" % (byteWidth, self.height))
            self.backing_store_sizes.add((byteWidth, self.height))
            cycleCount += 6
        
        cycleCount, optimizationCount = self.generateBlitter(colorStreams, maskStreams, cycleCount)

        if not self.clobber:
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
        self.out()
        self.asm("rts")
        self.comment("Cycle count: %d, Optimized %d rows." % (cycleCount,optimizationCount))

    def generateBlitter(self, colorStreams, maskStreams, baseCycleCount):
        byteWidth = len(colorStreams[0])
        
        cycleCount = baseCycleCount
        optimizationCount = 0

        for row in range(self.height):
            cycleCount += self.rowStartCalculatorCode(row)

            byteSplits = colorStreams[row]
            maskSplits = maskStreams[row]
            byteCount = len(byteSplits)

            # number of trailing iny to remove due to unchanged bytes at the
            # end of the row
            skip_iny = 0

            # Generate blitting code
            for index, (value, mask) in enumerate(zip(byteSplits, maskSplits)):
                if index > 0:
                    self.asm("iny")
                    cycleCount += 2

                # Optimization
                if mask == "01111111":
                    optimizationCount += 1
                    self.comment_line("byte %d: skipping! unchanged byte (mask = %s)" % (index, mask))
                    skip_iny += 1
                else:
                    value = self.binary_constant(value)
                    skip_iny = 0
                    # Store byte into video memory
                    if self.xdraw:
                        self.asm("lda (SCRATCH0),y")
                        self.asm("eor %s" % value)
                        self.asm("sta (SCRATCH0),y");
                        cycleCount += 5 + 2 + 6
                    elif self.use_mask:
                        if mask == "00000000":
                            # replacing all the bytes; no need for and/or!
                            self.asm("lda %s" % value)
                            self.asm("sta (SCRATCH0),y");
                            cycleCount += 2 + 5
                        else:
                            mask = self.binary_constant(mask)
                            self.asm("lda (SCRATCH0),y")
                            self.asm("and %s" % mask)
                            self.asm("ora %s" % value)
                            self.asm("sta (SCRATCH0),y");
                            cycleCount += 5 + 2 + 2 + 6
                    else:
                        self.asm("lda %s" % value)
                        self.asm("sta (SCRATCH0),y");
                        cycleCount += 2 + 6

            while skip_iny > 0:
                self.pop_asm("iny")
                skip_iny -= 1
                cycleCount -= 2

        return cycleCount, optimizationCount

    def rowStartCalculatorCode(self, row):
        self.out()
        self.comment_line("row %d" % row)
        if row == 0:
            self.asm("ldx PARAM1")
            cycles = 3
        else:
            self.asm("inx")
            cycles = 2
        self.asm("lda HGRROWS_H1,x")
        self.asm("sta SCRATCH1")
        self.asm("lda HGRROWS_L,x")
        self.asm("sta SCRATCH0")
        if row == 0:
            self.asm("ldy PARAM0")
            self.asm("lda DIV%d_%d,y" % (self.screen.numShifts, self.screen.bitsPerPixel))
            self.asm("sta PARAM2")  # save the mod lookup; it doesn't change
            self.asm("tay")
            cycles += 3 + 4 + 3 + 2
        else:
            self.asm("ldy PARAM2")
            cycles += 2
        return cycles + 4 + 3 + 4 + 3;


def shiftStringRight(string, shift, bitsPerPixel, fillerBit):
    if shift==0:
        return string
    
    shift *= bitsPerPixel
    result = ""
    
    for i in range(shift):
        result += fillerBit
        
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
        if pixel == self.black or pixel == self.key:
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
        if pixel == self.key:
            return "11"

        return "00"

    def highBitForColor(self, pixel):
        # Note that we prefer high-bit white because blue fringe is less noticeable than magenta.
        highBit = "0"
        if pixel == self.orange or pixel == self.blue or pixel == self.white:
            highBit = "1"

        return highBit

    def highBitForMask(self, pixel):
        return "0"

    def pixelColor(self, pixelData, row, col):
        r = pixelData[row][col*3]
        g = pixelData[row][col*3+1]
        b = pixelData[row][col*3+2]

        rhi = r == 255
        rlo = r == 0
        ghi = g == 255
        glo = g == 0
        bhi = b == 255
        blo = b == 0

        if rhi and ghi and bhi:
            color = self.white
        elif rlo and glo and blo:
            color = self.black
        elif rhi and bhi:
            color = self.magenta
        elif rhi and g > 0:
            color = self.orange
        elif bhi:
            color = self.blue
        elif ghi:
            color = self.green
        else:
            # anything else is chroma key
            color = self.key
        return color

    def byteStreamsFromPixels(self, shift, source, mask=False):
        byteStreams = ["" for x in range(source.height)]
        byteWidth = self.byteWidth(source.width)

        if mask:
            bitDelegate = self.bitsForMask
            highBitDelegate = self.highBitForMask
            fillerBit = "1"
        else:
            bitDelegate = self.bitsForColor
            highBitDelegate = self.highBitForColor
            fillerBit = "0"

        for row in range(source.height):
            bitStream = ""
            highBit = "0"
            highBitFound = False
            
            # Compute raw bitstream for row from PNG pixels
            for pixelIndex in range(source.width):
                pixel = self.pixelColor(source.pixelData,row,pixelIndex)
                bitStream += bitDelegate(pixel)

                # Determine palette bit from first non-black pixel on each row
                if not highBitFound and pixel != self.black and pixel != self.key:
                    highBit = highBitDelegate(pixel)
                    highBitFound = True
            
            # Shift bit stream as needed
            bitStream = shiftStringRight(bitStream, shift, self.bitsPerPixel, fillerBit)
            bitStream = bitStream[:byteWidth*8]
            
            # Split bitstream into bytes
            bitPos = 0
            byteSplits = [0 for x in range(byteWidth)]
            
            for byteIndex in range(byteWidth):
                remainingBits = len(bitStream) - bitPos
                    
                bitChunk = ""
                
                if remainingBits < 0:
                    bitChunk = fillerBit * 7
                else:   
                    if remainingBits < 7:
                        bitChunk = bitStream[bitPos:]
                        bitChunk += fillerBit * (7-remainingBits)
                    else:   
                        bitChunk = bitStream[bitPos:bitPos+7]
                
                bitChunk = bitChunk[::-1]
                
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
            return "1"
        return "0"

    def pixelColor(self, pixelData, row, col):
        r = pixelData[row][col*3]
        g = pixelData[row][col*3+1]
        b = pixelData[row][col*3+2]
        color = self.black
        
        if abs(r - g) < 16 and abs(g - b) < 16 and r!=0 and r!=255:   # Any grayish color is chroma key
            color = self.key
        elif r>25 or g>25 or b>25:  # pretty much all other colors are white
            color = self.white
        else:
            color = self.black
        return color


class RowLookup(Listing):
    def __init__(self, assembler, screen):
        Listing.__init__(self, assembler)
        self.slug = "hgrrows"
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
        self.slug = "hgrcols-%dx%d" % (screen.numShifts, screen.bitsPerPixel)
        self.generate_x(screen)

    def generate_x(self, screen):
        self.out("\n")
        self.label("DIV%d_%d" % (screen.numShifts, screen.bitsPerPixel))
        for pixel in range(screen.numX):
            self.byte("$%02x" % ((pixel / screen.numShifts) * screen.bitsPerPixel), screen.numShifts)

        self.out("\n")
        self.label("MOD%d_%d" % (screen.numShifts, screen.bitsPerPixel))
        for pixel in range(screen.numX):
            # This is the index into the jump table, so it's always multiplied
            # by 2
            self.byte("$%02x" % ((pixel % screen.numShifts) * 2), screen.numShifts)


class BackingStore(Listing):
    # Each entry in the stack includes:
    # 2 bytes: address of restore routine
    # 1 byte: x coordinate
    # 1 byte: y coordinate
    # nn: x * y bytes of data, in lists of rows

    def __init__(self, assembler, byte_width, row_height):
        Listing.__init__(self, assembler)
        self.byte_width = byte_width
        self.row_height = row_height
        self.save_label = "savebg_%dx%d" % (byte_width, row_height)
        self.restore_label = "restorebg_%dx%d" % (byte_width, row_height)
        self.space_needed = self.compute_size()
        self.create_save()
        self.out()
        self.create_restore()
        self.out()

    def compute_size(self):
        return 2 + 1 + 1 + (self.byte_width * self.row_height)

    def create_save(self):
        self.label(self.save_label)

        # reserve space in the backing store stack
        self.asm("sec")
        self.asm("lda bgstore")
        self.asm("sbc #%d" % self.space_needed)
        self.asm("sta bgstore")
        self.asm("lda bgstore+1")
        self.asm("sbc #0")
        self.asm("sta bgstore+1")

        # save the metadata
        self.asm("ldy #0")
        self.asm("lda #<%s" % self.restore_label)
        self.asm("sta (bgstore),y")
        self.asm("iny")
        self.asm("lda #>%s" % self.restore_label)
        self.asm("sta (bgstore),y")
        self.asm("iny")
        self.asm("lda PARAM0")
        self.asm("sta (bgstore),y")
        self.asm("iny")
        self.asm("lda PARAM1")

        # Note that we can't clobber PARAM1 like the restore routine can
        # because this is called in the sprite drawing routine and these
        # values must be retained to draw the sprite in the right place!
        self.asm("sta SCRATCH0")
        self.asm("sta (bgstore),y")
        self.asm("iny")

        loop_label, col_label = self.smc_row_col(self.save_label, "SCRATCH0")

        for c in range(self.byte_width):
            self.label(col_label % c)
            self.asm("lda $2000,x")
            self.asm("sta (bgstore),y")
            self.asm("iny")
            if c < self.byte_width - 1:
                # last loop doesn't need this
                self.asm("inx")

        self.asm("inc SCRATCH0")

        self.asm("cpy #%d" % self.space_needed)
        self.asm("bcc %s" % loop_label)

        self.asm("rts")

    def smc_row_col(self, label, row_var):
        # set up smc for hires column, because the starting column doesn't
        # change when moving to the next row
        self.asm("ldx PARAM0")
        self.asm("lda DIV7_1,x")
        smc_label = "%s_smc1" % label
        self.asm("sta %s+1" % smc_label)

        loop_label = "%s_line" % label
        # save a line, starting from the topmost and working down
        self.label(loop_label)
        self.asm("ldx %s" % row_var)

        self.asm("lda HGRROWS_H1,x")
        col_label = "%s_col%%s" % label
        for c in range(self.byte_width):
            self.asm("sta %s+2" % (col_label % c))
        self.asm("lda HGRROWS_L,x")
        for c in range(self.byte_width):
            self.asm("sta %s+1" % (col_label % c))

        self.label(smc_label)
        self.asm("ldx #$ff")
        return loop_label, col_label

    def create_restore(self):
        # bgstore will be pointing right to the data to be blitted back to the
        # screen, which is 4 bytes into the bgstore array. Everything before
        # the data will have already been pulled off by the driver in order to
        # figure out which restore routine to call.  Y will be 4 upon entry,
        # and PARAM0 and PARAM1 will be filled with the x & y values.
        #
        # also, no need to save registers because this is being called from a
        # driver that will do all of that.
        self.label(self.restore_label)

        # we can clobber the heck out of PARAM1 because we're being called from
        # the restore driver and when we return we are just going to load it up
        # with the next value anyway.
        loop_label, col_label = self.smc_row_col(self.restore_label, "PARAM1")

        for c in range(self.byte_width):
            self.asm("lda (bgstore),y")
            self.label(col_label % c)
            self.asm("sta $2000,x")
            self.asm("iny")
            if c < self.byte_width - 1:
                # last loop doesn't need this
                self.asm("inx")

        self.asm("inc PARAM1")
        self.asm("cpy #%d" % self.space_needed)
        self.asm("bcc %s" % loop_label)

        self.asm("rts")


class BackingStoreDriver(Listing):
    # Driver to restore the screen using all the saved data.
    # The backing store is a stack that grows downward in order to restore the
    # chunks in reverse order that they were saved.
    #
    # variables used:
    #   bgstore: (lo byte, hi byte) 1 + the first byte of free memory.
    #            I.e. points just beyond the last byte
    #   PARAM0: (byte) x coord
    #   PARAM1: (byte) y coord
    #
    # everything else is known because the sizes of each erase/restore
    # routine are hardcoded because this is a sprite *compiler*.
    def __init__(self, assembler, sizes):
        Listing.__init__(self, assembler)
        self.slug = "backing-store"
        for byte_width, row_height in sizes:
            code = BackingStore(assembler, byte_width, row_height)
            self.add_listing(code)



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
    parser.add_argument("-m", "--mask", action="store_true", default=False, help="use mask for sprite drawing")
    parser.add_argument("-b", "--backing-store", action="store_true", default=False, help="add code to store background")
    parser.add_argument("-a", "--assembler", default="cc65", choices=["cc65","mac65"], help="Assembler syntax (default: %(default)s)")
    parser.add_argument("-p", "--processor", default="any", choices=["any","6502", "65C02"], help="Processor type (default: %(default)s)")
    parser.add_argument("-s", "--screen", default="hgrcolor", choices=["hgrcolor","hgrbw"], help="Screen format (default: %(default)s)")
    parser.add_argument("-n", "--name", default="", help="Name for generated assembly function (default: based on image filename)")
    parser.add_argument("-k", "--clobber", action="store_true", default=False, help="don't save the registers on the stack")
    parser.add_argument("-o", "--output-prefix", default="", help="Base name to create a set of output files. If not supplied, all code will be sent to stdout.")
    parser.add_argument("files", metavar="IMAGE", nargs="*", help="a PNG image [or a list of them]. PNG files must not have an alpha channel!")
    options, extra_args = parser.parse_known_args()

    if options.assembler.lower() == "cc65":
        assembler = CC65()
    elif options.assembler.lower() == "mac65":
        assembler = Mac65()
    else:
        print("Unknown assembler %s" % options.assembler)
        parser.print_help()
        sys.exit(1)

    if options.screen.lower() == "hgrcolor":
        screen = HGR()
    elif options.screen.lower() == "hgrbw":
        screen = HGRBW()
    else:
        print("Unknown screen format %s" % options.screen)
        parser.print_help()
        sys.exit(1)

    listings = []
    luts = {}  # dict of lookup tables to prevent duplication in output files

    for pngfile in options.files:
        try:
            sprite_code = Sprite(pngfile, assembler, screen, options.xdraw, options.mask, options.backing_store, options.clobber, options.processor, options.name)
        except RuntimeError, e:
            print "%s: %s" % (pngfile, e)
            sys.exit(1)
        except png.Error, e:
            print "%s: %s" % (pngfile, e)
            sys.exit(1)
        listings.append(sprite_code)
        if options.output_prefix:
            r = RowLookup(assembler, screen)
            luts[r.slug] = r
            c = ColLookup(assembler, screen)
            luts[c.slug] = c

    listings.extend([luts[k] for k in sorted(luts.keys())])

    if options.rows:
        listings.append(RowLookup(assembler, screen))

    if options.cols:
        listings.append(ColLookup(assembler, screen))

    if listings:
        if options.output_prefix:
            if Sprite.backing_store_sizes:
                backing_store_code = BackingStoreDriver(assembler, Sprite.backing_store_sizes)
                listings.append(backing_store_code)
            driver = Listing(assembler)
            for source in listings:
                genfile = source.write(options.output_prefix, disclaimer)
                driver.include(genfile)
            driver.write(options.output_prefix, disclaimer)
        else:
            print disclaimer

            for section in listings:
                print section
