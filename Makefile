#
#  Makefile
#  HGR
#
#  Created by Quinn Dunki on 7/19/16
#  One Girl, One Laptop Productions
#  http://www.quinndunki.com
#  http://www.quinndunki.com/blondihacks
#


CFGDIR=/usr/local/share/cc65
CL65=/usr/local/bin/cl65 --cfg-path $(CFGDIR)/cfg --lib-path $(CFGDIR)/lib
AC=AppleCommander.jar
ADDR=6000

PGM=hisprite

all: hisprite hisprite-2plus


hisprite:
	$(CL65) -t apple2enh --start-addr $(ADDR) -l$(PGM).lst -o $(PGM) $(PGM).s
	java -jar $(AC) -d $(PGM).dsk $(PGM)
	java -jar $(AC) -p $(PGM).dsk $(PGM) BIN 0x$(ADDR) < $(PGM)
	#rm -f $(PGM)
	#rm -f $(PGM).o
	#osascript V2Make.scpt $(PROJECT_DIR) $(PGM)

hisprite-2plus:
	$(CL65) -t apple2 --cpu 6502 --start-addr 0x$(ADDR) -l$(PGM)-2plus.lst -o $(PGM)-2plus $(PGM).s
	atrcopy game.dsk boot -b hisprite-2plus --brun 6000 -f

clean:
	rm -f $(PGM)
	rm -f $(PGM).o
	rm -f $(PGM)-2plus
	rm -f $(PGM)-2plus.o
