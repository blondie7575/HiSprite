; Driver to restore the screen using all the saved data.
;
; The backing store is a stack that grows downward in order to restore the
; chunks in reverse order that they were saved. Each entry in the stack
; includes:
;
;  2 bytes: address of restore routine
;  1 byte: x coordinate
;  1 byte: y coordinate
;  nn: x * y bytes of data, in lists of rows
;
; Note that sprites of different sizes will have different sized entries
; in the stack, so the entire list has to be processed in order. But you want
; that anyway, so it's not a big deal.
;
; The global variable 'bgstore' is used as the stack pointer. It musts be
; initialized to a page boundary, the stack grows downward from there.
; starting from the last byte on the previous page. E.g. if the initial
; value is $c000, the stack grows down using $bfff as the highest address,
; the initial bgstore value must point to 1 + the last usable byte
;
; All registers are clobbered because there's no real need to save them since
; this will be called from the main game loop.

restorebg_init
    lda #0          ; init backing store to end of free memory, $c000
    sta bgstore
    lda #BGTOP
    sta bgstore+1
    rts


restorebg_driver
    ldy #0
    lda (bgstore),y
    sta restorebg_jsr+1
    iny
    lda (bgstore),y
    sta restorebg_jsr+2
    iny
    lda (bgstore),y
    sta PARAM0
    iny 
    lda (bgstore),y
    sta PARAM1
    iny
restorebg_jsr
    jsr $ffff

    clc
    tya         ; y contains the number of bytes processed
    adc bgstore
    sta bgstore
    lda bgstore+1
    adc #0
    sta bgstore+1
    cmp #BGTOP
    bcc restorebg_driver
    rts
