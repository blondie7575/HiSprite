;
;  macros.s
;  Generally useful macros for 6502 code
;
;  Created by Quinn Dunki on 8/15/14.
;  Copyright (c) 2014 One Girl, One Laptop Productions. All rights reserved.
;


; Macros

.macro SETSWITCH name		; Sets the named softswitch (assumes write method)
	sta name
.endmacro


.macro SAVE_AXY				; Saves all registers
	pha
	phx
	phy
.endmacro


.macro RESTORE_AXY			; Restores all registers
	ply
	plx
	pla
.endmacro


.macro SAVE_AY				; Saves accumulator and Y index
	pha
	phy
.endmacro


.macro RESTORE_AY			; Restores accumulator and Y index
	ply
	pla
.endmacro


.macro SAVE_AX				; Saves accumulator and X index
	pha
	phx
.endmacro


.macro RESTORE_AX			; Restores accumulator and X index
	plx
	pla
.endmacro


.macro SAVE_XY				; Saves X and Y index
	phx
	phy
.endmacro


.macro RESTORE_XY			; Restores X and Y index
	ply
	plx
.endmacro


.macro SAVE_ZPP				; Saves Zero Page locations we use for parameters
	lda	PARAM0
	pha
	lda PARAM1
	pha
	lda PARAM2
	pha
	lda PARAM3
	pha
.endmacro


.macro RESTORE_ZPP			; Restores Zero Page locations we use for parameters
	pla
	sta PARAM3
	pla
	sta PARAM2
	pla
	sta PARAM1
	pla
	sta PARAM0
.endmacro


.macro SAVE_ZPS				; Saves Zero Page locations we use for scratch
	lda	SCRATCH0
	pha
	lda SCRATCH1
	pha
.endmacro


.macro RESTORE_ZPS			; Restores Zero Page locations we use for scratch
	pla
	sta	SCRATCH1
	pla
	sta	SCRATCH0
.endmacro


.macro PARAM16 addr
	lda #<addr
	sta PARAM0
	lda #>addr
	sta PARAM1
.endmacro


.macro CALL16 func,addr
	PARAM16 addr
	jsr func
.endmacro


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Rendering macros
;

.macro VBL_SYNC			; Synchronize with vertical blanking
@macroWaitVBLToFinish:
	lda $C019
	bpl @macroWaitVBLToFinish
@macroWaitVBLToStart:
	lda $C019
	bmi @macroWaitVBLToStart
.endmacro
