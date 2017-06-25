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

    *= $80
drawptr .ds 2


    *= $6000

start
    bit CLRTEXT     ; start with HGR page 1, full screen
    bit CLRMIXED
    bit TXTPAGE1
    bit SETHIRES

gameloop
    jmp draw

    jsr clrscr

    ldx #0
?1
    txa
    sta $2000,x
    inx
    bne ?1

; Draw sprites by looping through the list of sprites
renderinit
    lda #<drawlist
    sta drawptr
    lda #>drawlist
    sta drawptr+1
    ldy #0

renderloop
    lda (drawptr),y
    sta jsrsprite+1
    iny
    lda (drawptr),y
    beq renderend       ; check high byte is 0 ==> end of list
    sta jsrsprite+2
    iny
    lda (drawptr),y     ; x coord
    sta PARAM0
    iny
    lda (drawptr),y     ; y coord
    sta PARAM1

jsrsprite
    jsr $ffff

    ; skip y coords
    iny
    iny
    bne renderLoop

    jsr wait
    inc PARAM0
    lda PARAM0
    cmp #100
    bcc checky
    lda #0
    sta PARAM0

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
    lda #MAXSPRITEINDEX
    sta spriteNum
    jmp renderLoop


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


drawlist
    .word SPRITE1
    .word SPRITE2
    .word 0


SPRITE1
    .word COLORSPRITE
    .byte 80    ; X pos
    .byte 116   ; Y pos
    .byte -1        ; X vec
    .byte -3        ; Y vec

SPRITE2
    .word BWSPRITE
    .byte 64    ; X pos
    .byte 126   ; Y pos
    .byte 4 ; X vec
    .byte 3 ; Y vec


    .include colorsprite.s
    .include bwsprite.s
    .include rowlookup.s
    .include collookupbw.s
    .include collookupcolor.s
