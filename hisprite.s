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
SPRITEPTR_L		= $1b
SPRITEPTR_H		= $1c

MAXSPRITEINDEX	= 5		; Sprite count - 1
MAXPOSX			= 127	; This demo doesn't wanna do 16 bit math
MAXPOSY			= 127

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
	jsr VenetianFill

mainLoop:

; Draw sprites
renderLoop:

	; Find our sprite pointer
	lda spriteNum
	asl
	tax
	lda META_BUFFERS+1,x
	sta SPRITEPTR_H
	lda META_BUFFERS,x
	sta SPRITEPTR_L

	; Find Y coordinate
	ldy #1
	lda (SPRITEPTR_L),y
	sta PARAM1

	; Find X coordinate
	ldy #0
	lda (SPRITEPTR_L),y
	sta PARAM0

	jsr BOXW_MAG

	; Next sprite
	dec spriteNum
	bmi restartList
	jmp renderLoop

restartList:
	lda #MAXSPRITEINDEX
	sta spriteNum

	VBL_SYNC


; Background restore
backgroundLoop:

	; Find our sprite pointer
	lda spriteNum
	asl
	tax
	lda META_BUFFERS+1,x
	sta SPRITEPTR_H
	lda META_BUFFERS,x
	sta SPRITEPTR_L

	; Find Y coordinate
	ldy #1
	lda (SPRITEPTR_L),y
	sta PARAM1

	; Find X coordinate
	ldy #0
	lda (SPRITEPTR_L),y
	sta PARAM0

	jsr BlackRect

	; Next sprite
	dec spriteNum
	bmi backgroundRestartList
	jmp backgroundLoop

backgroundRestartList:
	lda #MAXSPRITEINDEX
	sta spriteNum
jmp mainLoop		; Skip movement

movementLoop:
	; Find our sprite pointer
	lda spriteNum
	asl
	tax
	lda META_BUFFERS+1,x
	sta SPRITEPTR_H
	lda META_BUFFERS,x
	sta SPRITEPTR_L

	; Apply X velocity to X coordinate
	clc
	ldy #0
	lda (SPRITEPTR_L),y
	ldy #2
	adc (SPRITEPTR_L),y
	bmi flipX
	cmp #MAXPOSX
	bpl flipX

	; Store the new X
	ldy #0
	sta (SPRITEPTR_L),y

adjustY:
	; Apply Y velocity to Y coordinate
	clc
	ldy #1
	lda (SPRITEPTR_L),y
	ldy #3
	adc (SPRITEPTR_L),y
	bmi flipY
	cmp #MAXPOSY
	bpl flipY

	; Store the new Y
	ldy #1
	sta (SPRITEPTR_L),y

continueMovementList:
	dec spriteNum
	bmi movementRestartList
	jmp movementLoop

flipX:
	lda (SPRITEPTR_L),y
	eor #$ff
	inc
	sta (SPRITEPTR_L),y
	bra adjustY

flipY:
	lda (SPRITEPTR_L),y
	eor #$ff
	inc
	sta (SPRITEPTR_L),y
	bra continueMovementList

movementRestartList:
	lda #MAXSPRITEINDEX
	sta spriteNum
	jmp renderLoop


	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; delayShort
; Sleeps for ~1/30th second
;
delayShort:
	SAVE_AXY

	ldy		#$06	; Loop a bit
delayShortOuter:
	ldx		#$ff
delayShortInner:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	dex
	bne		delayShortInner
	dey
	bne		delayShortOuter

	RESTORE_AXY
	rts



spriteNum:
	.byte MAXSPRITEINDEX
bgFilename:
	.byte "KOL",0

.include "graphics.s"
.include "hgrtableX.s"
.include "hgrtableY.s"
.include "spriteBuffers.s"
.include "spritegen0.s"
;.include "spritegen1.s"
;.include "spritegen2.s"
;.include "spritegen3.s"
;.include "spritegen4.s"

; Suppress some linker warnings - Must be the last thing in the file
.SEGMENT "ZPSAVE"
.SEGMENT "EXEHDR"
.SEGMENT "STARTUP"
.SEGMENT "INIT"
.SEGMENT "LOWCODE"
