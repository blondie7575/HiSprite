;
;  graphics.s
;
;  Created by Quinn Dunki on 9/10/16
;  Copyright (c) 2015 One Girl, One Laptop Productions. All rights reserved.
;


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
; SaveBackground
; PARAM0: X pos
; PARAM1: Y pos
; PARAM2: Storage area (LSB)
; PARAM3: Storage area (MSB)
;
; Assumes 6-byte-wide, 8px-high sprites
;
SaveBackground:
	SAVE_AXY
	ldy #0
	lda #0
	pha

saveBackground_loop:
	clc
	pla
	pha
	adc	PARAM1	; Calculate Y line
	tax

	lda HGRROWS_H,x			; Compute hires row
	sta saveBackground_smc0+2
	sta saveBackground_smc1+2
	sta saveBackground_smc2+2
	sta saveBackground_smc3+2
	lda HGRROWS_L,x
	sta saveBackground_smc0+1
	sta saveBackground_smc1+1
	sta saveBackground_smc2+1
	sta saveBackground_smc3+1

	ldx PARAM0				; Compute hires column
	lda DIV7_2,x
	tax

saveBackground_smc0:
	lda $2000,x
	sta (PARAM2),y
	iny
	inx
saveBackground_smc1:
	lda $2000,x
	sta (PARAM2),y
	iny
	inx
saveBackground_smc2:
	lda $2000,x
	sta (PARAM2),y
	iny
	inx
saveBackground_smc3:
	lda $2000,x
	sta (PARAM2),y
	iny

	pla
	inc
	pha

	cpy #48
	bne saveBackground_loop

	pla
	RESTORE_AXY
	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RestoreBackground
; PARAM0: X pos
; PARAM1: Y pos
; PARAM2: Storage area (LSB)
; PARAM3: Storage area (MSB)
;
; Assumes 4-byte-wide, 8px-high sprites
;
RestoreBackground:
	SAVE_AXY
	ldy #0
	lda #0
	pha

restoreBackground_loop:
	clc
	pla
	pha
	adc	PARAM1	; Calculate Y line
	tax

	lda HGRROWS_H,x			; Compute hires row
	sta restoreBackground_smc0+2
	sta restoreBackground_smc1+2
	sta restoreBackground_smc2+2
	sta restoreBackground_smc3+2
	lda HGRROWS_L,x
	sta restoreBackground_smc0+1
	sta restoreBackground_smc1+1
	sta restoreBackground_smc2+1
	sta restoreBackground_smc3+1

	ldx PARAM0				; Compute hires column
	lda DIV7_2,x
	tax

	lda (PARAM2),y
restoreBackground_smc0:
	sta $2000,x
	iny
	inx

	lda (PARAM2),y
restoreBackground_smc1:
	sta $2000,x
	iny
	inx

	lda (PARAM2),y
restoreBackground_smc2:
	sta $2000,x
	iny
	inx

	lda (PARAM2),y
restoreBackground_smc3:
	sta $2000,x
	iny

	pla
	inc
	pha

	cpy #48
	bne restoreBackground_loop

	pla
	RESTORE_AXY
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

