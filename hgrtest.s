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

.if 1

	ldx #0
loop:
	txa
	asl
	asl
	sta PARAM0
	lda #80
	sta PARAM1
	lda #<BOX_MAG_SHIFT0
	sta PARAM2
	lda #>BOX_MAG_SHIFT0
	sta PARAM3
	jsr BlitSprite

;	lda #$ff
;	jsr ROMWAIT

	inx
	cpx #35
	bne loop

.endif
.if 0
	BLITBYTE 0,80,BOX_MAG_SHIFT0_CHUNK0
	BLITBYTE 1,80,BOX_MAG_SHIFT0_CHUNK1
	BLITBYTE 2,80,BOX_MAG_SHIFT0_CHUNK2

	BLITBYTE 0,90,BOX_MAG_SHIFT1_CHUNK0
	BLITBYTE 1,90,BOX_MAG_SHIFT1_CHUNK1
	BLITBYTE 2,90,BOX_MAG_SHIFT1_CHUNK2

	BLITBYTE 0,100,BOX_MAG_SHIFT2_CHUNK0
	BLITBYTE 1,100,BOX_MAG_SHIFT2_CHUNK1
	BLITBYTE 2,100,BOX_MAG_SHIFT2_CHUNK2

	BLITBYTE 0,110,BOX_MAG_SHIFT3_CHUNK0
	BLITBYTE 1,110,BOX_MAG_SHIFT3_CHUNK1
	BLITBYTE 2,110,BOX_MAG_SHIFT3_CHUNK2

	BLITBYTE 0,120,BOX_MAG_SHIFT4_CHUNK0
	BLITBYTE 1,120,BOX_MAG_SHIFT4_CHUNK1
	BLITBYTE 2,120,BOX_MAG_SHIFT4_CHUNK2

	BLITBYTE 0,130,BOX_MAG_SHIFT5_CHUNK0
	BLITBYTE 1,130,BOX_MAG_SHIFT5_CHUNK1
	BLITBYTE 2,130,BOX_MAG_SHIFT5_CHUNK2

	BLITBYTE 0,140,BOX_MAG_SHIFT6_CHUNK0
	BLITBYTE 1,140,BOX_MAG_SHIFT6_CHUNK1
	BLITBYTE 2,140,BOX_MAG_SHIFT6_CHUNK2




	BLITBYTE 4,80,BOX_GRN_SHIFT0_CHUNK0
	BLITBYTE 5,80,BOX_GRN_SHIFT0_CHUNK1
	BLITBYTE 6,80,BOX_GRN_SHIFT0_CHUNK2

	BLITBYTE 4,90,BOX_GRN_SHIFT1_CHUNK0
	BLITBYTE 5,90,BOX_GRN_SHIFT1_CHUNK1
	BLITBYTE 6,90,BOX_GRN_SHIFT1_CHUNK2

	BLITBYTE 4,100,BOX_GRN_SHIFT2_CHUNK0
	BLITBYTE 5,100,BOX_GRN_SHIFT2_CHUNK1
	BLITBYTE 6,100,BOX_GRN_SHIFT2_CHUNK2

	BLITBYTE 4,110,BOX_GRN_SHIFT3_CHUNK0
	BLITBYTE 5,110,BOX_GRN_SHIFT3_CHUNK1
	BLITBYTE 6,110,BOX_GRN_SHIFT3_CHUNK2

	BLITBYTE 4,120,BOX_GRN_SHIFT4_CHUNK0
	BLITBYTE 5,120,BOX_GRN_SHIFT4_CHUNK1
	BLITBYTE 6,120,BOX_GRN_SHIFT4_CHUNK2

	BLITBYTE 4,130,BOX_GRN_SHIFT5_CHUNK0
	BLITBYTE 5,130,BOX_GRN_SHIFT5_CHUNK1
	BLITBYTE 6,130,BOX_GRN_SHIFT5_CHUNK2

	BLITBYTE 4,140,BOX_GRN_SHIFT6_CHUNK0
	BLITBYTE 5,140,BOX_GRN_SHIFT6_CHUNK1
	BLITBYTE 6,140,BOX_GRN_SHIFT6_CHUNK2

.endif


.if 0
	BLITBYTE 20,80,MAG0
	BLITBYTE 21,80,MAG1

	BLITBYTE 20,90,MAG2
	BLITBYTE 21,90,MAG3

	BLITBYTE 20,100,MAG4
	BLITBYTE 21,100,MAG5

	BLITBYTE 20,110,MAG6
	BLITBYTE 21,110,MAG7

	BLITBYTE 21,120,MAG8
	BLITBYTE 22,120,MAG9

	BLITBYTE 21,130,MAG10
	BLITBYTE 22,130,MAG11

	BLITBYTE 21,140,MAG12
	BLITBYTE 22,140,MAG13
.endif

.if 0

	BLITBYTE 22,80,GRN0
	BLITBYTE 23,80,GRN1

	BLITBYTE 22,90,GRN2
	BLITBYTE 23,90,GRN3

	BLITBYTE 22,100,GRN4
	BLITBYTE 23,100,GRN5

	BLITBYTE 22,110,GRN6
	BLITBYTE 23,110,GRN7

	BLITBYTE 23,120,GRN8
	BLITBYTE 24,120,GRN9

	BLITBYTE 23,130,GRN10
	BLITBYTE 24,130,GRN11

	BLITBYTE 23,140,GRN12
	BLITBYTE 24,140,GRN13
.endif


.if 0
	BLITBYTE 20,80,BOX_MAG0
	BLITBYTE 21,80,BOX_MAG1

	BLITBYTE 20,90,BOX_MAG2
	BLITBYTE 21,90,BOX_MAG3

	BLITBYTE 20,100,BOX_MAG4
	BLITBYTE 21,100,BOX_MAG5

	BLITBYTE 20,110,BOX_MAG6
	BLITBYTE 21,110,BOX_MAG7

	BLITBYTE 21,120,BOX_MAG8
	BLITBYTE 22,120,BOX_MAG9

	BLITBYTE 21,130,BOX_MAG10
	BLITBYTE 22,130,BOX_MAG11

	BLITBYTE 21,140,BOX_MAG12
	BLITBYTE 22,140,BOX_MAG13
.endif

.if 0
	BLITBYTE 20,80,BOX_GRN0

	BLITBYTE 20,90,BOX_GRN1
	BLITBYTE 21,90,BOX_GRN2

	BLITBYTE 20,100,BOX_GRN3
	BLITBYTE 21,100,BOX_GRN4

	BLITBYTE 20,110,BOX_GRN5
	BLITBYTE 21,110,BOX_GRN6

	BLITBYTE 21,120,BOX_GRN7
	BLITBYTE 22,120,BOX_GRN8

	BLITBYTE 21,130,BOX_GRN9
	BLITBYTE 22,130,BOX_GRN10

	BLITBYTE 21,140,BOX_GRN11
	BLITBYTE 22,140,BOX_GRN12
.endif


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.if 0
	BLITBYTE 20,80,BOX0
	WAIT
	BLITBYTE 20,80,BLACK

	BLITBYTE 20,80,BOX1
	BLITBYTE 21,80,BOX2
	WAIT
	BLITBYTE 20,80,BLACK
	BLITBYTE 21,80,BLACK

	BLITBYTE 20,80,BOX3
	BLITBYTE 21,80,BOX4
	WAIT
	BLITBYTE 20,80,BLACK
	BLITBYTE 21,80,BLACK

	BLITBYTE 20,80,BOX5
	BLITBYTE 21,80,BOX6
	WAIT
	BLITBYTE 20,80,BLACK
	BLITBYTE 21,80,BLACK

	BLITBYTE 21,80,BOX7
	BLITBYTE 22,80,BOX8
	WAIT
	BLITBYTE 21,80,BLACK
	BLITBYTE 22,80,BLACK

	BLITBYTE 21,80,BOX9
	BLITBYTE 22,80,BOX10
	WAIT
	BLITBYTE 21,80,BLACK
	BLITBYTE 22,80,BLACK

	BLITBYTE 21,80,BOX11
	BLITBYTE 22,80,BOX12
	WAIT
	BLITBYTE 21,80,BLACK
	BLITBYTE 22,80,BLACK

	BLITBYTE 22,80,BOX0
	WAIT
	BLITBYTE 22,80,BLACK

	jmp loop
.endif


	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BlitSprite
; Trashes everything, including parameters
; PARAM0: X Pos
; PARAM1: Y Pos
; PARAM2: Sprite Ptr LSB
; PARAM3: Sprite Ptr MSB
;
BlitSprite:
	SAVE_AXY

	clc						; Compute sprite data base
	ldx PARAM0
	lda HGRROWS_BITSHIFT_GRN,x
	adc PARAM2
	sta PARAM2
	lda #0
	adc PARAM3
	sta PARAM3

	lda #7
	sta SCRATCH0			; Tracks row index

	asl						; Multiply by byte width
	asl
	sta SCRATCH1			; Tracks total bytes
	ldy #0

blitSprite_Yloop:
	clc						; Calculate Y line on screen
	lda SCRATCH0
	adc	PARAM1
	tax

	lda HGRROWS_H,x			; Compute hires row
	sta blitSprite_smc+2	; Self-modifying code
	sta blitSprite_smc+5
	lda HGRROWS_L,x
	sta blitSprite_smc+1
	sta blitSprite_smc+4

	ldx PARAM0				; Compute hires horizontal byte
	lda HGRROWS_GRN,x
	tax

blitSprite_Xloop:
	lda (PARAM2),y

blitSprite_smc:
	ora $2000,x
	sta $2000,x
	inx
	iny
	tya						; End of row?
	and #$03				; If last two bits are zero, we've wrapped a row
	bne blitSprite_Xloop

	dec SCRATCH0
	bpl blitSprite_Yloop

	RESTORE_AXY
	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BlitSpriteOnByte
; Trashes everything
; PARAM0: X Byte
; PARAM1: Y Pos
; PARAM2: Sprite Ptr MSB
; PARAM3: Sprite Ptr LSB
;
BlitSpriteOnByte:
	ldy #7

blitSpriteOnByte_loop:
	clc
	tya
	adc	PARAM1	; Calculate Y line
	tax

	lda HGRROWS_H,x			; Compute hires row
	sta blitSpriteOnByte_smc+2
	lda HGRROWS_L,x
	sta blitSpriteOnByte_smc+1

	ldx PARAM0				; Compute hires column
	lda (PARAM2),y

blitSpriteOnByte_smc:
	sta $2000,x
	dey
	bpl blitSpriteOnByte_loop
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
.include "hgrtable2.s"
.include "spritedata0.s"
.include "spritedata1.s"
.include "spritegen0.s"
.include "spritegen1.s"


; Suppress some linker warnings - Must be the last thing in the file
.SEGMENT "ZPSAVE"
.SEGMENT "EXEHDR"
.SEGMENT "STARTUP"
.SEGMENT "INIT"
.SEGMENT "LOWCODE"
