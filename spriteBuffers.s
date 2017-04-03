;
;  spriteBuffers.s
;
;  Created by Quinn Dunki on 7/19/16
;  Copyright (c) 2015 One Girl, One Laptop Productions. All rights reserved.
;

BG_BUFFERS:
	.addr bgBuffer0
	.addr bgBuffer1
	.addr bgBuffer2
	.addr bgBuffer3
	.addr bgBuffer4
	.addr bgBuffer5
	.addr bgBuffer6
	.addr bgBuffer7
	.addr bgBuffer8
	.addr bgBuffer9

META_BUFFERS:
	.addr metaBuffer0
	.addr metaBuffer1
	.addr metaBuffer2
	.addr metaBuffer3
	.addr metaBuffer4
	.addr metaBuffer5
	.addr metaBuffer6
	.addr metaBuffer7
	.addr metaBuffer8
	.addr metaBuffer9

metaBuffer0:
	.byte 0	; X pos
	.byte 0	; Y pos

metaBuffer1:
	.byte 0	; X pos
	.byte 10	; Y pos

metaBuffer2:
	.byte 0	; X pos
	.byte 20	; Y pos

metaBuffer3:
	.byte 0	; X pos
	.byte 30	; Y pos

metaBuffer4:
	.byte 0	; X pos
	.byte 40	; Y pos

metaBuffer5:
	.byte 0	; X pos
	.byte 50	; Y pos

metaBuffer6:
	.byte 0	; X pos
	.byte 60	; Y pos

metaBuffer7:
	.byte 0	; X pos
	.byte 70	; Y pos

metaBuffer8:
	.byte 0	; X pos
	.byte 80	; Y pos

metaBuffer9:
	.byte 0	; X pos
	.byte 90	; Y pos

bgBuffer0:
.repeat 48
	.byte 0
.endrepeat

bgBuffer1:
.repeat 48
.byte 0
.endrepeat

bgBuffer2:
.repeat 48
.byte 0
.endrepeat

bgBuffer3:
.repeat 48
.byte 0
.endrepeat

bgBuffer4:
.repeat 48
.byte 0
.endrepeat

bgBuffer5:
.repeat 48
.byte 0
.endrepeat

bgBuffer6:
.repeat 48
.byte 0
.endrepeat

bgBuffer7:
.repeat 48
.byte 0
.endrepeat

bgBuffer8:
.repeat 48
.byte 0
.endrepeat

bgBuffer9:
.repeat 48
.byte 0
.endrepeat

