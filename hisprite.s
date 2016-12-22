;
;  hisprite.s
;
;  Created by Quinn Dunki on 7/19/16
;  Copyright (c) 2015 One Girl, One Laptop Productions. All rights reserved.
;


.org $6000

.include "macros.s"

; Softswitches
TEXT = $c050
HIRES1 = $c057
HIRES2 = $c058


; ROM entry points
COUT = $fded
ROMWAIT = $fca8

; Zero page locations we use (unused by Monitor, Applesoft, or ProDOS)
PARAM0			= $06
PARAM1			= $07
PARAM2			= $08
PARAM3			= $09
SCRATCH0		= $19
SCRATCH1		= $1a

; Macros
.macro BLITBYTE xPos,yPos,addr
	lda #xPos
	sta PARAM0
	lda #yPos
	sta PARAM1
	lda #<addr
	sta PARAM2
	lda #>addr
	sta PARAM3
	jsr BlitSpriteOnByte
.endmacro

.macro BLIT xPos,yPos,addr
	lda #xPos
	sta PARAM0
	lda #yPos
	sta PARAM1
	lda #<addr
	sta PARAM2
	lda #>addr
	sta PARAM3
	jsr BlitSprite
.endmacro


.macro WAIT
	lda #$80
	jsr $fca8
.endmacro



main:
	jsr EnableHires

;	lda #$00
;	jsr VenetianFill

	lda #<bgFilename
	sta PARAM0
	lda #>bgFilename
	sta PARAM1
	jsr BloadHires


	ldx #0
;;;;
;	stz PARAM0
;	stz PARAM1
;	jsr BOXW_MAG
;
;	lda #10
;	sta PARAM1
;	jsr BOXW_MIX
;
;	lda #20
;	sta PARAM1
;	jsr BOXW_ORG
;
;	rts
;;;;

loop:
	txa
	sta PARAM0
	lda #0
	sta PARAM1

	lda #<bgBuffer
	sta PARAM2
	lda #>bgBuffer
	sta PARAM3
	jsr SaveBackground

	jsr BOXW_MAG
	lda #$80
	jsr ROMWAIT

	jsr RestoreBackground

	inx
	cpx #133
	bne loop
	rts

bgBuffer:
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0

bgFilename:
	.byte "KOL",0

.include "graphics.s"
.include "hgrtableX.s"
.include "hgrtableY.s"
.include "spritegen0.s"
.include "spritegen1.s"
.include "spritegen2.s"
.include "spritegen3.s"
.include "spritegen4.s"

; Suppress some linker warnings - Must be the last thing in the file
.SEGMENT "ZPSAVE"
.SEGMENT "EXEHDR"
.SEGMENT "STARTUP"
.SEGMENT "INIT"
.SEGMENT "LOWCODE"
