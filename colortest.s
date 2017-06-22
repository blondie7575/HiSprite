    *= $6000

; os memory map
CLRTEXT = $c050
SETTEXT = $c051
CLRMIXED = $c052
SETMIXED = $c053
TXTPAGE1 = $c054
TXTPAGE2 = $c055
CLRHIRES = $c056
SETHIRES = $c057

; ROM entry points
COUT = $fded
ROMWAIT = $fca8

; Zero page locations we use (unused by Monitor, Applesoft, or ProDOS)
PARAM0          = $06
PARAM1          = $07
PARAM2          = $08
PARAM3          = $09
SCRATCH0        = $19
SCRATCH1        = $1a
SPRITEPTR_L     = $1b
SPRITEPTR_H     = $1c

start   
    bit CLRTEXT     ; start with HGR page 1, full screen
    bit CLRMIXED
    bit TXTPAGE1
    bit SETHIRES

    jmp draw

    jsr clrscr

    ldx #0
?1
    txa
    sta $2000,x
    inx
    bne ?1

draw
    lda #100
    sta PARAM1 ; y coord
    lda #0
    sta PARAM0 ; x coord

loop
    jsr COLORSPRITE

    jsr wait
    inc PARAM0
    lda PARAM0
    cmp #100
    bcc checky
    lda #0
    sta PARAM0

checky
    inc PARAM1
    lda PARAM1
    cmp #100
    bcc loop
    lda #0
    sta PARAM1
    beq loop

wait
    ldy     #$06    ; Loop a bit
wait_outer
    ldx     #$ff
wait_inner
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    dex
    bne     wait_inner
    dey
    bne     wait_outer
    rts


clrscr
    lda #0
    sta clr1+1
    lda #$20
    sta clr1+2
clr0
    lda #$81
    ldy #0
clr1
    sta $ffff,y
    iny
    bne clr1
    inc clr1+2
    ldx clr1+2
    cpx #$40
    bcc clr1
    rts

    .include colorsprite.s
