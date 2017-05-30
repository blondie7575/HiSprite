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
	lda PAGE1
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

	lda HGRROWS_H1,x			; Compute hires row
	sta saveBackground_smc0+2
	sta saveBackground_smc1+2
	sta saveBackground_smc2+2
	sta saveBackground_smc3+2
	sta saveBackground_smc4+2
	sta saveBackground_smc5+2
	lda HGRROWS_L,x
	sta saveBackground_smc0+1
	sta saveBackground_smc1+1
	sta saveBackground_smc2+1
	sta saveBackground_smc3+1
	sta saveBackground_smc4+1
	sta saveBackground_smc5+1

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
	inx
saveBackground_smc4:
	lda $2000,x
	sta (PARAM2),y
	iny
	inx
saveBackground_smc5:
	lda $2000,x
	sta (PARAM2),y
	iny

	pla
.ifpC02
	inc
.else
	clc
	adc #1
.endif
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

	lda HGRROWS_H1,x			; Compute hires row
	sta restoreBackground_smc0+2
	sta restoreBackground_smc1+2
	sta restoreBackground_smc2+2
	sta restoreBackground_smc3+2
	sta restoreBackground_smc4+2
	sta restoreBackground_smc5+2
	lda HGRROWS_L,x
	sta restoreBackground_smc0+1
	sta restoreBackground_smc1+1
	sta restoreBackground_smc2+1
	sta restoreBackground_smc3+1
	sta restoreBackground_smc4+1
	sta restoreBackground_smc5+1

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
	inx

	lda (PARAM2),y
restoreBackground_smc4:
	sta $2000,x
	iny
	inx

	lda (PARAM2),y
restoreBackground_smc5:
	sta $2000,x
	iny

	pla
.ifpC02
	inc
.else
	clc
	adc #1
.endif
	pha

	cpy #48
	bne restoreBackground_loop

	pla
	RESTORE_AXY
	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BlackRect
; PARAM0: X pos
; PARAM1: Y pos
;
; Assumes 4-byte-wide, 8px-high sprites
;
BlackRect:
	SAVE_AX
	lda #0
	pha

blackRect_loop:
	clc
	pla
	pha
	adc	PARAM1	; Calculate Y line
	tax

	lda HGRROWS_H1,x			; Compute hires row
	sta blackRect_smc0+2
	sta blackRect_smc1+2
	sta blackRect_smc2+2
	sta blackRect_smc3+2
	sta blackRect_smc4+2
	sta blackRect_smc5+2
	lda HGRROWS_L,x
	sta blackRect_smc0+1
	sta blackRect_smc1+1
	sta blackRect_smc2+1
	sta blackRect_smc3+1
	sta blackRect_smc4+1
	sta blackRect_smc5+1

	ldx PARAM0				; Compute hires column
	lda DIV7_2,x
	tax

.ifpC02
.else
	lda #0
.endif
blackRect_smc0:
.ifpC02
	stz $2000,x
.else
	sta $2000,x
.endif
	inx

blackRect_smc1:
.ifpC02
	stz $2000,x
.else
	sta $2000,x
.endif
	inx

blackRect_smc2:
.ifpC02
	stz $2000,x
.else
	sta $2000,x
.endif
	inx

blackRect_smc3:
.ifpC02
	stz $2000,x
.else
	sta $2000,x
.endif
	inx

blackRect_smc4:
.ifpC02
	stz $2000,x
.else
	sta $2000,x
.endif
	inx

blackRect_smc5:
.ifpC02
	stz $2000,x
.else
	sta $2000,x
.endif

	pla
.ifpC02
	inc
.else
	clc
	adc #1
.endif
	pha

	cmp #8
	bne blackRect_loop

	pla
	RESTORE_AX
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
	lda HGRROWS_H1,x
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


INBUF			= $0200
DOSCMD			= $be03
KBD				= $c000
KBDSTRB			= $c010


; ProDOS v2 only works on 65C02, so skip this stuff for classic 6502 support
.ifpC02
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CommandLine
;
; PARAM0: Command line string (LSB)
; PARAM1: Command line string (MSB)
;
CommandLine:
	SAVE_AXY
	ldx #0
	ldy #0

CommandLine_loop:
	lda (PARAM0),y
	beq CommandLine_done
	sta $0200,x						; Keyboard input buffer
	inx
	iny
	bra CommandLine_loop

CommandLine_done:
	lda #$8d						; Terminate with return and null
	sta $0200,x
	inx
	lda #0
	sta $0200,x

	jsr $be03						; ProDOS 8 entry point

	RESTORE_AXY
	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BloadHires
;
; PARAM0: Filename (LSB)
; PARAM1: Filename (MSB)
;
; Max filename length: 16 chars!
;
BloadHires:
	SAVE_AXY
	ldx #0
	ldy #0

BloadHires_loop:
	lda (PARAM0),y				; Copy filename into BLOAD buffer
	beq BloadHires_done
	sta BloadHires_buffer+6,x
	inx
	iny
	bra BloadHires_loop

BloadHires_done:
	lda #<BloadHires_buffer
	sta PARAM0
	lda #>BloadHires_buffer
	sta PARAM1
	jsr CommandLine

	RESTORE_AXY
	rts

BloadHires_buffer:
	.byte "BLOAD ",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.endif
