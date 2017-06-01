
; This file was generated by HiSprite.py, a sprite compiler by Quinn Dunki.
; If you feel the need to modify this file, you are probably doing it wrong.

BOXW_MAG: ;6 bytes per row
	SAVE_AXY
	ldy PARAM0
	ldx MOD7_2,y
.ifpC02
	jmp (BOXW_MAG_JMP,x)

BOXW_MAG_JMP:
	.addr BOXW_MAG_SHIFT0
	.addr BOXW_MAG_SHIFT1
	.addr BOXW_MAG_SHIFT2
	.addr BOXW_MAG_SHIFT3
	.addr BOXW_MAG_SHIFT4
	.addr BOXW_MAG_SHIFT5
	.addr BOXW_MAG_SHIFT6
.else
	lda BOXW_MAG_JMP+1,x
	pha
	lda BOXW_MAG_JMP,x
	pha
	rts

BOXW_MAG_JMP:
	.addr BOXW_MAG_SHIFT0-1
	.addr BOXW_MAG_SHIFT1-1
	.addr BOXW_MAG_SHIFT2-1
	.addr BOXW_MAG_SHIFT3-1
	.addr BOXW_MAG_SHIFT4-1
	.addr BOXW_MAG_SHIFT5-1
	.addr BOXW_MAG_SHIFT6-1
.endif


BOXW_MAG_SHIFT0:
	ldx PARAM1
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%01010101
	sta (SCRATCH0),y
	iny
	lda #%00101010
	sta (SCRATCH0),y
	iny
	lda #%00000001
	sta (SCRATCH0),y
	iny
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%00000001
	sta (SCRATCH0),y
	iny
	iny
	lda #%00000001
	sta (SCRATCH0),y
	iny
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%01010001
	sta (SCRATCH0),y
	iny
	lda #%00001010
	sta (SCRATCH0),y
	iny
	lda #%00000001
	sta (SCRATCH0),y
	iny
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%00010001
	sta (SCRATCH0),y
	iny
	lda #%00001000
	sta (SCRATCH0),y
	iny
	lda #%00000001
	sta (SCRATCH0),y
	iny
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%00010001
	sta (SCRATCH0),y
	iny
	lda #%00001000
	sta (SCRATCH0),y
	iny
	lda #%00000001
	sta (SCRATCH0),y
	iny
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%01010001
	sta (SCRATCH0),y
	iny
	lda #%00001010
	sta (SCRATCH0),y
	iny
	lda #%00000001
	sta (SCRATCH0),y
	iny
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%00000001
	sta (SCRATCH0),y
	iny
	iny
	lda #%00000001
	sta (SCRATCH0),y
	iny
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%01010101
	sta (SCRATCH0),y
	iny
	lda #%00101010
	sta (SCRATCH0),y
	iny
	lda #%00000001
	sta (SCRATCH0),y
	iny
	iny
	iny

	RESTORE_AXY
	rts	;Cycle count: 497, Optimized 26 rows.



BOXW_MAG_SHIFT1:
	ldx PARAM1
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%01010100
	sta (SCRATCH0),y
	iny
	lda #%00101010
	sta (SCRATCH0),y
	iny
	lda #%00000101
	sta (SCRATCH0),y
	iny
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%00000100
	sta (SCRATCH0),y
	iny
	iny
	lda #%00000100
	sta (SCRATCH0),y
	iny
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%01000100
	sta (SCRATCH0),y
	iny
	lda #%00101010
	sta (SCRATCH0),y
	iny
	lda #%00000100
	sta (SCRATCH0),y
	iny
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%01000100
	sta (SCRATCH0),y
	iny
	lda #%00100000
	sta (SCRATCH0),y
	iny
	lda #%00000100
	sta (SCRATCH0),y
	iny
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%01000100
	sta (SCRATCH0),y
	iny
	lda #%00100000
	sta (SCRATCH0),y
	iny
	lda #%00000100
	sta (SCRATCH0),y
	iny
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%01000100
	sta (SCRATCH0),y
	iny
	lda #%00101010
	sta (SCRATCH0),y
	iny
	lda #%00000100
	sta (SCRATCH0),y
	iny
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%00000100
	sta (SCRATCH0),y
	iny
	iny
	lda #%00000100
	sta (SCRATCH0),y
	iny
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%01010100
	sta (SCRATCH0),y
	iny
	lda #%00101010
	sta (SCRATCH0),y
	iny
	lda #%00000101
	sta (SCRATCH0),y
	iny
	iny
	iny

	RESTORE_AXY
	rts	;Cycle count: 497, Optimized 26 rows.



BOXW_MAG_SHIFT2:
	ldx PARAM1
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%01010000
	sta (SCRATCH0),y
	iny
	lda #%00101010
	sta (SCRATCH0),y
	iny
	lda #%00010101
	sta (SCRATCH0),y
	iny
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%00010000
	sta (SCRATCH0),y
	iny
	iny
	lda #%00010000
	sta (SCRATCH0),y
	iny
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%00010000
	sta (SCRATCH0),y
	iny
	lda #%00101010
	sta (SCRATCH0),y
	iny
	lda #%00010001
	sta (SCRATCH0),y
	iny
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%00010000
	sta (SCRATCH0),y
	iny
	lda #%00000010
	sta (SCRATCH0),y
	iny
	lda #%00010001
	sta (SCRATCH0),y
	iny
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%00010000
	sta (SCRATCH0),y
	iny
	lda #%00000010
	sta (SCRATCH0),y
	iny
	lda #%00010001
	sta (SCRATCH0),y
	iny
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%00010000
	sta (SCRATCH0),y
	iny
	lda #%00101010
	sta (SCRATCH0),y
	iny
	lda #%00010001
	sta (SCRATCH0),y
	iny
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%00010000
	sta (SCRATCH0),y
	iny
	iny
	lda #%00010000
	sta (SCRATCH0),y
	iny
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%01010000
	sta (SCRATCH0),y
	iny
	lda #%00101010
	sta (SCRATCH0),y
	iny
	lda #%00010101
	sta (SCRATCH0),y
	iny
	iny
	iny

	RESTORE_AXY
	rts	;Cycle count: 497, Optimized 26 rows.



BOXW_MAG_SHIFT3:
	ldx PARAM1
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%01000000
	sta (SCRATCH0),y
	iny
	lda #%00101010
	sta (SCRATCH0),y
	iny
	lda #%01010101
	sta (SCRATCH0),y
	iny
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%01000000
	sta (SCRATCH0),y
	iny
	iny
	lda #%01000000
	sta (SCRATCH0),y
	iny
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%01000000
	sta (SCRATCH0),y
	iny
	lda #%00101000
	sta (SCRATCH0),y
	iny
	lda #%01000101
	sta (SCRATCH0),y
	iny
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%01000000
	sta (SCRATCH0),y
	iny
	lda #%00001000
	sta (SCRATCH0),y
	iny
	lda #%01000100
	sta (SCRATCH0),y
	iny
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%01000000
	sta (SCRATCH0),y
	iny
	lda #%00001000
	sta (SCRATCH0),y
	iny
	lda #%01000100
	sta (SCRATCH0),y
	iny
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%01000000
	sta (SCRATCH0),y
	iny
	lda #%00101000
	sta (SCRATCH0),y
	iny
	lda #%01000101
	sta (SCRATCH0),y
	iny
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%01000000
	sta (SCRATCH0),y
	iny
	iny
	lda #%01000000
	sta (SCRATCH0),y
	iny
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	lda #%01000000
	sta (SCRATCH0),y
	iny
	lda #%00101010
	sta (SCRATCH0),y
	iny
	lda #%01010101
	sta (SCRATCH0),y
	iny
	iny
	iny

	RESTORE_AXY
	rts	;Cycle count: 497, Optimized 26 rows.



BOXW_MAG_SHIFT4:
	ldx PARAM1
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	iny
	lda #%00101010
	sta (SCRATCH0),y
	iny
	lda #%01010101
	sta (SCRATCH0),y
	iny
	lda #%00000010
	sta (SCRATCH0),y
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	iny
	lda #%00000010
	sta (SCRATCH0),y
	iny
	iny
	lda #%00000010
	sta (SCRATCH0),y
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	iny
	lda #%00100010
	sta (SCRATCH0),y
	iny
	lda #%00010101
	sta (SCRATCH0),y
	iny
	lda #%00000010
	sta (SCRATCH0),y
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	iny
	lda #%00100010
	sta (SCRATCH0),y
	iny
	lda #%00010000
	sta (SCRATCH0),y
	iny
	lda #%00000010
	sta (SCRATCH0),y
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	iny
	lda #%00100010
	sta (SCRATCH0),y
	iny
	lda #%00010000
	sta (SCRATCH0),y
	iny
	lda #%00000010
	sta (SCRATCH0),y
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	iny
	lda #%00100010
	sta (SCRATCH0),y
	iny
	lda #%00010101
	sta (SCRATCH0),y
	iny
	lda #%00000010
	sta (SCRATCH0),y
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	iny
	lda #%00000010
	sta (SCRATCH0),y
	iny
	iny
	lda #%00000010
	sta (SCRATCH0),y
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	iny
	lda #%00101010
	sta (SCRATCH0),y
	iny
	lda #%01010101
	sta (SCRATCH0),y
	iny
	lda #%00000010
	sta (SCRATCH0),y
	iny
	iny

	RESTORE_AXY
	rts	;Cycle count: 497, Optimized 26 rows.



BOXW_MAG_SHIFT5:
	ldx PARAM1
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	iny
	lda #%00101000
	sta (SCRATCH0),y
	iny
	lda #%01010101
	sta (SCRATCH0),y
	iny
	lda #%00001010
	sta (SCRATCH0),y
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	iny
	lda #%00001000
	sta (SCRATCH0),y
	iny
	iny
	lda #%00001000
	sta (SCRATCH0),y
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	iny
	lda #%00001000
	sta (SCRATCH0),y
	iny
	lda #%01010101
	sta (SCRATCH0),y
	iny
	lda #%00001000
	sta (SCRATCH0),y
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	iny
	lda #%00001000
	sta (SCRATCH0),y
	iny
	lda #%01000001
	sta (SCRATCH0),y
	iny
	lda #%00001000
	sta (SCRATCH0),y
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	iny
	lda #%00001000
	sta (SCRATCH0),y
	iny
	lda #%01000001
	sta (SCRATCH0),y
	iny
	lda #%00001000
	sta (SCRATCH0),y
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	iny
	lda #%00001000
	sta (SCRATCH0),y
	iny
	lda #%01010101
	sta (SCRATCH0),y
	iny
	lda #%00001000
	sta (SCRATCH0),y
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	iny
	lda #%00001000
	sta (SCRATCH0),y
	iny
	iny
	lda #%00001000
	sta (SCRATCH0),y
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	iny
	lda #%00101000
	sta (SCRATCH0),y
	iny
	lda #%01010101
	sta (SCRATCH0),y
	iny
	lda #%00001010
	sta (SCRATCH0),y
	iny
	iny

	RESTORE_AXY
	rts	;Cycle count: 497, Optimized 26 rows.



BOXW_MAG_SHIFT6:
	ldx PARAM1
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	iny
	lda #%00100000
	sta (SCRATCH0),y
	iny
	lda #%01010101
	sta (SCRATCH0),y
	iny
	lda #%00101010
	sta (SCRATCH0),y
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	iny
	lda #%00100000
	sta (SCRATCH0),y
	iny
	iny
	lda #%00100000
	sta (SCRATCH0),y
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	iny
	lda #%00100000
	sta (SCRATCH0),y
	iny
	lda #%01010100
	sta (SCRATCH0),y
	iny
	lda #%00100010
	sta (SCRATCH0),y
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	iny
	lda #%00100000
	sta (SCRATCH0),y
	iny
	lda #%00000100
	sta (SCRATCH0),y
	iny
	lda #%00100010
	sta (SCRATCH0),y
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	iny
	lda #%00100000
	sta (SCRATCH0),y
	iny
	lda #%00000100
	sta (SCRATCH0),y
	iny
	lda #%00100010
	sta (SCRATCH0),y
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	iny
	lda #%00100000
	sta (SCRATCH0),y
	iny
	lda #%01010100
	sta (SCRATCH0),y
	iny
	lda #%00100010
	sta (SCRATCH0),y
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	iny
	lda #%00100000
	sta (SCRATCH0),y
	iny
	iny
	lda #%00100000
	sta (SCRATCH0),y
	iny
	iny

	inx
	lda HGRROWS_H1,x
	sta SCRATCH1
	lda HGRROWS_L,x
	sta SCRATCH0
	ldy PARAM0
	lda DIV7_2,y
	tay

	iny
	lda #%00100000
	sta (SCRATCH0),y
	iny
	lda #%01010101
	sta (SCRATCH0),y
	iny
	lda #%00101010
	sta (SCRATCH0),y
	iny
	iny

	RESTORE_AXY
	rts	;Cycle count: 497, Optimized 26 rows.



