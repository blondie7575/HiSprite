;
;  hgrtest.s
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

	lda #$00
	jsr LinearFill

	ldx #0
loop:
	txa
	asl
	asl
	sta PARAM0
	lda #0
	sta PARAM1
	jsr BOX_MAG

	lda #88
	sta PARAM1
	jsr BOX_GRN

	lda #96
	sta PARAM1
	jsr BOX_ORG

	lda #184
	sta PARAM1
	jsr BOX_BLU

	inx
	cpx #35
	bne loop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; EnableHires
; Trashes A
;
EnableHires:
	lda TEXT
	lda HIRES1
	lda HIRES2
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; LinearFill
; A: Byte value to fill
; Trashes all registers
;
LinearFill:
	ldx #0

linearFill_outer:
	pha
	lda HGRROWS_H,x
	sta linearFill_inner+2
	lda HGRROWS_L,x
	sta linearFill_inner+1
	pla

	ldy #39
linearFill_inner:
	sta $2000,y
	dey
	bpl linearFill_inner

	inx
	cpx #192
	bne linearFill_outer
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; VenetianFill
; A: Byte value to fill
; Trashes all registers
;
VenetianFill:
	ldx #$3f
venetianFill_outer:
	stx venetianFill_inner+2
	ldy #$00
venetianFill_inner:
	sta $2000,y		; Upper byte of address is self-modified
	iny
	bne venetianFill_inner
	dex
	cpx #$1f
	bne venetianFill_outer
	rts


.include "hgrtableX.s"
.include "hgrtableY.s"
.include "spritegen0.s"
.include "spritegen1.s"
.include "spritegen2.s"
.include "spritegen3.s"

; Suppress some linker warnings - Must be the last thing in the file
.SEGMENT "ZPSAVE"
.SEGMENT "EXEHDR"
.SEGMENT "STARTUP"
.SEGMENT "INIT"
.SEGMENT "LOWCODE"
