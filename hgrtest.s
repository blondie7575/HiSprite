;
;  hgrtest.s
;
;  Created by Quinn Dunki on 7/19/16
;  Copyright (c) 2015 One Girl, One Laptop Productions. All rights reserved.
;


.org $6000


; Softswitches
TEXT = $c050
HIRES1 = $c057
HIRES2 = $c058


; ROM entry points
COUT = $fded


; Zero page locations we use (unused by Monitor, Applesoft, or ProDOS)
PARAM0			= $06
PARAM1			= $07
PARAM2			= $08
PARAM3			= $09
SCRATCH0		= $19
SCRATCH1		= $1a

; Macros
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

loop:
	lda #$00
	jsr LinearFill


.if 0
	BLIT 20,80,SPRITE0

	BLIT 20,90,SPRITE1
	BLIT 21,90,SPRITE2

	BLIT 20,100,SPRITE3
	BLIT 21,100,SPRITE4

	BLIT 20,110,SPRITE5
	BLIT 21,110,SPRITE6

	BLIT 21,120,SPRITE7
	BLIT 22,120,SPRITE8

	BLIT 21,130,SPRITE9
	BLIT 22,130,SPRITE10

	BLIT 21,140,SPRITE11
	BLIT 22,140,SPRITE12

	BLIT 22,150,SPRITE0
.endif
;rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	BLIT 20,80,SPRITE0
	WAIT
	BLIT 20,80,BLACK

	BLIT 20,80,SPRITE1
	BLIT 21,80,SPRITE2
	WAIT
	BLIT 20,80,BLACK
	BLIT 21,80,BLACK

	BLIT 20,80,SPRITE3
	BLIT 21,80,SPRITE4
	WAIT
	BLIT 20,80,BLACK
	BLIT 21,80,BLACK

	BLIT 20,80,SPRITE5
	BLIT 21,80,SPRITE6
	WAIT
	BLIT 20,80,BLACK
	BLIT 21,80,BLACK

	BLIT 21,80,SPRITE7
	BLIT 22,80,SPRITE8
	WAIT
	BLIT 21,80,BLACK
	BLIT 22,80,BLACK

	BLIT 21,80,SPRITE9
	BLIT 22,80,SPRITE10
	WAIT
	BLIT 21,80,BLACK
	BLIT 22,80,BLACK

	BLIT 21,80,SPRITE11
	BLIT 22,80,SPRITE12
	WAIT
	BLIT 21,80,BLACK
	BLIT 22,80,BLACK

	BLIT 22,80,SPRITE0
	WAIT
	BLIT 22,80,BLACK

	jmp loop
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BlitSprite
; Trashes everything
; PARAM0: X Pos
; PARAM1: Y Pos
; PARAM2: Sprite Ptr MSB
; PARAM3: Sprite Ptr LSB
;
BlitSprite:
	ldy #7

blitSprite_loop:
	clc
	tya
	adc	PARAM1	; Calculate Y line
	tax

	lda HGRROWS_H,x			; Compute hires row
	sta blitSprite_smc+2
	lda HGRROWS_L,x
	sta blitSprite_smc+1

	ldx PARAM0				; Compute hires column
	lda (PARAM2),y

blitSprite_smc:
	sta $2000,x
	dey
	bpl blitSprite_loop
	rts


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


.include "hgrtable.s"
.include "spritedata.s"


; Suppress some linker warnings - Must be the last thing in the file
.SEGMENT "ZPSAVE"
.SEGMENT "EXEHDR"
.SEGMENT "STARTUP"
.SEGMENT "INIT"
.SEGMENT "LOWCODE"
