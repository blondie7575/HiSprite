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
TEXT2 = $c051
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

MAXSPRITEINDEX		= 3		; Sprite count - 1
MAXPOSX				= 127	; This demo doesn't wanna do 16 bit math
MAXPOSY				= 127
MAXLOCALBATCHINDEX	= 3		; Sprites in batch - 1
MAXBATCHINDEX		= 0		; Number of batches - 1

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
	jsr checkKbd

renderLoop:

	; Find our sprite pointer
	lda spriteNum ; 4
	asl ; 2
	tax ; 2
	lda META_BUFFERS+1,x ; 4
	sta SPRITEPTR_H ; 3
	lda META_BUFFERS,x ; 4
	sta SPRITEPTR_L ; 3

	; Find Y coordinate
	ldy #1 ; 2
	lda (SPRITEPTR_L),y ; 5
	sta PARAM1 ; 3

	; Find X coordinate
	ldy #0 ; 2
	lda (SPRITEPTR_L),y ; 5
	sta PARAM0 ; 3

	jsr SPACESHIP ; 6		48 cycles overhead to here

	; Next sprite
	dec spriteNum ; 6
	dec batchLocalIndex ; 6
	bmi restartList ; 2
	jmp renderLoop ; 3			65 cycles overhead per sprite

restartList:
	lda batchMaxIndex
	sta spriteNum
	lda #MAXLOCALBATCHINDEX
	sta batchLocalIndex

;	jmp batchLoop
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

	jsr BLACK

	; Next sprite
	dec spriteNum
	dec batchLocalIndex
	bmi backgroundRestartList
	jmp backgroundLoop		; 65 cycles overhead per rect

backgroundRestartList:
	lda batchMaxIndex
	sta spriteNum
	lda #MAXLOCALBATCHINDEX
	sta batchLocalIndex

;	jmp batchLoop		; Skip movement

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

batchLoop:
	dec batchIndex
	bpl batchContinue

	lda #MAXBATCHINDEX
	sta batchIndex
	lda #MAXSPRITEINDEX
	sta spriteNum

batchContinue:
	jmp mainLoop


	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; checkKbd
; Exits app on a keystroke
;
checkKbd:
;	rts
	lda $c000
	bpl checkKbdDone
	sta $c010

	cmp #241		; 'q' with high bit set
	bne	checkKbdDone

	jsr EnableText

;	pla		; Pull our own frame off the stack...
;	pla
;	pla
;	pla
	pla		; ...four local variables + return address...
	pla
	rts		; ...so we can quit to ProDOS from here

checkKbdDone:
	rts


spriteNum:
	.byte MAXSPRITEINDEX
batchIndex:
	.byte MAXBATCHINDEX
batchMaxIndex:
	.byte MAXSPRITEINDEX
batchLocalIndex:
	.byte MAXLOCALBATCHINDEX


bgFilename:
	.byte "KOL",0

.include "graphics.s"
.include "hgrtableX.s"
.include "hgrtableY.s"
.include "spriteBuffers.s"
.include "spritegen0.s"
.include "spritegen0b.s"
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
