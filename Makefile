#
#  Makefile
#  HGR
#
#  Created by Quinn Dunki on 7/19/16
#  One Girl, One Laptop Productions
#  http://www.quinndunki.com
#  http://www.quinndunki.com/blondihacks
#


CL65=cl65
AC=AppleCommander.jar
ADDR=6000

PGM=hgrtest

all: $(PGM)


$(PGM):
	@PATH=$(PATH):/usr/local/bin; $(CL65) -t apple2enh --start-addr $(ADDR) -l$(PGM).lst $(PGM).s
	java -jar $(AC) -d $(PGM).dsk $(PGM)
	java -jar $(AC) -p $(PGM).dsk $(PGM) BIN 0x$(ADDR) < $(PGM)
	rm -f $(PGM)
	rm -f $(PGM).o
	osascript V2Make.scpt $(PROJECT_DIR) $(PGM)

clean:
	rm -f $(PGM)
	rm -f $(PGM).o

