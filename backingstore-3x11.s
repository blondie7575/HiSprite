; backing store test, hardcoded for 3x11 apple.png-sized sprite
;
; The backing store memory starts from some high address
; and grows downward in order to facilitate speedier restoring, because
; there will be different sized chunks to restore
;
;
;
;
; needs:
;   bgstore: (lo byte, hi byte) 1 + the first byte of free memory.
;            I.e. points just beyond the last byte
;   PARAM0: (byte) x coord
;   PARAM1: (byte) y coord
;
; everything else is known because the sizes of each erase/restore
; routine will be hardcoded.

; modification of quinn's column sweep

; memory needed for this chunk of background:
;  2: address of restore routine
;  1: x coordinate
;  1: y coordinate
;  33: number of bytes of background to save
SIZE_3X11 = 2 + 1 + 1 + 3*11

savebg_3x11
    ; reserve space in the backing store stack
    sec
    lda bgstore
    sbc #SIZE_3X11
    sta bgstore
    lda bgstore+1
    sbc #0
    sta bgstore+1

    ; save the metadata
    ldy #0
    lda #<restorebg_3x11
    sta (bgstore),y
    iny
    lda #>restorebg_3x11
    sta (bgstore),y
    iny
    lda PARAM0
    sta (bgstore),y
    iny
    lda PARAM1
    sta SCRATCH0
    sta (bgstore),y
    iny

savebg_3x11_line
    ; save a line, starting from the topmost and working down
    ldx SCRATCH0  ; Calculate Y line

    lda HGRROWS_H1,x                        ; Compute hires row
    sta savebg_3x11_col0+2
    sta savebg_3x11_col1+2
    sta savebg_3x11_col2+2
    lda HGRROWS_L,x
    sta savebg_3x11_col0+1
    sta savebg_3x11_col1+1
    sta savebg_3x11_col2+1

    ldx PARAM0                              ; Compute hires column
    lda DIV7_1,x
    tax

savebg_3x11_col0
    lda $2000,x
    sta (bgstore),y
    iny
    inx
savebg_3x11_col1
    lda $2000,x
    sta (bgstore),y
    iny
    inx
savebg_3x11_col2
    lda $2000,x
    sta (bgstore),y
    iny

    inc SCRATCH0

    cpy #SIZE_3X11
    bcc savebg_3x11_line

    rts

; bgstore will be pointing right to the data to be blitted back to the screen,
; which is 4 bytes into the bgstore array. Everything before the data will have
; already been pulled off by the driver in order to figure out which restore
; routine to call.  Y will be 4 upon entry, and PARAM0 and PARAM1 will be
; filled with the x & y values.
;
; also, no need to save registers because this is being called from a driver
; that will do all of that.
restorebg_3x11
    ldx PARAM1  ; Calculate Y line

    lda HGRROWS_H1,x                        ; Compute hires row
    sta restorebg_3x11_col0+2
    sta restorebg_3x11_col1+2
    sta restorebg_3x11_col2+2
    lda HGRROWS_L,x
    sta restorebg_3x11_col0+1
    sta restorebg_3x11_col1+1
    sta restorebg_3x11_col2+1

    ldx PARAM0                              ; Compute hires column
    lda DIV7_1,x
    tax

    lda (bgstore),y
restorebg_3x11_col0
    sta $2000,x
    iny
    inx
    lda (bgstore),y
restorebg_3x11_col1
    sta $2000,x
    iny
    inx
    lda (bgstore),y
restorebg_3x11_col2
    sta $2000,x
    iny

    inc PARAM1

    cpy #SIZE_3X11
    bcc restorebg_3x11
    rts


SIZE_3X8 = 2 + 1 + 1 + 3*8

savebg_3X8
    ; reserve space in the backing store stack
    sec
    lda bgstore
    sbc #SIZE_3X8
    sta bgstore
    lda bgstore+1
    sbc #0
    sta bgstore+1

    ; save the metadata
    ldy #0
    lda #<restorebg_3X8
    sta (bgstore),y
    iny
    lda #>restorebg_3X8
    sta (bgstore),y
    iny
    lda PARAM0
    sta (bgstore),y
    iny
    lda PARAM1
    sta SCRATCH0
    sta (bgstore),y
    iny

savebg_3X8_line
    ; save a line, starting from the topmost and working down
    ldx SCRATCH0  ; Calculate Y line

    lda HGRROWS_H1,x                        ; Compute hires row
    sta savebg_3X8_col0+2
    sta savebg_3X8_col1+2
    sta savebg_3X8_col2+2
    lda HGRROWS_L,x
    sta savebg_3X8_col0+1
    sta savebg_3X8_col1+1
    sta savebg_3X8_col2+1

    ldx PARAM0                              ; Compute hires column
    lda DIV7_1,x
    tax

savebg_3X8_col0
    lda $2000,x
    sta (bgstore),y
    iny
    inx
savebg_3X8_col1
    lda $2000,x
    sta (bgstore),y
    iny
    inx
savebg_3X8_col2
    lda $2000,x
    sta (bgstore),y
    iny

    inc SCRATCH0

    cpy #SIZE_3X8
    bcc savebg_3X8_line

    rts

; bgstore will be pointing right to the data to be blitted back to the screen,
; which is 4 bytes into the bgstore array. Everything before the data will have
; already been pulled off by the driver in order to figure out which restore
; routine to call.  Y will be 4 upon entry, and PARAM0 and PARAM1 will be
; filled with the x & y values.
;
; also, no need to save registers because this is being called from a driver
; that will do all of that.
restorebg_3X8
    ldx PARAM1  ; Calculate Y line

    lda HGRROWS_H1,x                        ; Compute hires row
    sta restorebg_3X8_col0+2
    sta restorebg_3X8_col1+2
    sta restorebg_3X8_col2+2
    lda HGRROWS_L,x
    sta restorebg_3X8_col0+1
    sta restorebg_3X8_col1+1
    sta restorebg_3X8_col2+1

    ldx PARAM0                              ; Compute hires column
    lda DIV7_1,x
    tax

    lda (bgstore),y
restorebg_3X8_col0
    sta $2000,x
    iny
    inx
    lda (bgstore),y
restorebg_3X8_col1
    sta $2000,x
    iny
    inx
    lda (bgstore),y
restorebg_3X8_col2
    sta $2000,x
    iny

    inc PARAM1

    cpy #SIZE_3X8
    bcc restorebg_3X8
    rts
