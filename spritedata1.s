;
;  spritedata.s
;
;  Created by Quinn Dunki on 7/19/16
;  Copyright (c) 2015 One Girl, One Laptop Productions. All rights reserved.
;

GRN0:
	.byte	%00101010		; Byte aligned
	.byte	%00000010		; (reversed)
	.byte	%00000010
	.byte	%00000010
	.byte	%00000010
	.byte	%00000010
	.byte	%00000010
	.byte	%00101010

GRN1:
	.byte	%00000001		; Byte aligned
	.byte	%00000001		; (2nd byte, reversed)
	.byte	%00000001
	.byte	%00000001
	.byte	%00000001
	.byte	%00000001
	.byte	%00000001
	.byte	%00000001

GRN2:
	.byte	%00101000		; One pixel shift
	.byte	%00001000		; (reversed)
	.byte	%00001000
	.byte	%00001000
	.byte	%00001000
	.byte	%00001000
	.byte	%00001000
	.byte	%00101000

GRN3:
	.byte	%00000101		; One pixel shift
	.byte	%00000100		; (2nd byte, reversed)
	.byte	%00000100
	.byte	%00000100
	.byte	%00000100
	.byte	%00000100
	.byte	%00000100
	.byte	%00000101


GRN4:
	.byte	%00100000		; Two pixel shift
	.byte	%00100000		; (reversed)
	.byte	%00100000
	.byte	%00100000
	.byte	%00100000
	.byte	%00100000
	.byte	%00100000
	.byte	%00100000

GRN5:
	.byte	%00010101		; Two pixel shift
	.byte	%00010000		; (2nd byte, reversed)
	.byte	%00010000
	.byte	%00010000
	.byte	%00010000
	.byte	%00010000
	.byte	%00010000
	.byte	%00010101


GRN6:
	.byte	%00000000		; Three pixel shift
	.byte	%00000000		; (reversed)
	.byte	%00000000
	.byte	%00000000
	.byte	%00000000
	.byte	%00000000
	.byte	%00000000
	.byte	%00000000

GRN7:
	.byte	%01010101		; Three pixel shift
	.byte	%01000001		; (2nd byte, reversed)
	.byte	%01000001
	.byte	%01000001		;;;;;;;;;;;;;;;;;;;;
	.byte	%01000001
	.byte	%01000001
	.byte	%01000001
	.byte	%01010101


GRN8:
	.byte	%01010100		; Four pixel shift
	.byte	%00000100		; (reversed)
	.byte	%00000100
	.byte	%00000100
	.byte	%00000100
	.byte	%00000100
	.byte	%00000100
	.byte	%01010100

GRN9:
	.byte	%00000010		; Four pixel shift
	.byte	%00000010		; (2nd byte, reversed)
	.byte	%00000010
	.byte	%00000010
	.byte	%00000010
	.byte	%00000010
	.byte	%00000010
	.byte	%00000010


GRN10:
	.byte	%01010000		; Five pixel shift
	.byte	%00010000		; (reversed)
	.byte	%00010000
	.byte	%00010000
	.byte	%00010000
	.byte	%00010000
	.byte	%00010000
	.byte	%01010000

GRN11:
	.byte	%00001010		; Five pixel shift
	.byte	%00001000		; (2nd byte, reversed)
	.byte	%00001000
	.byte	%00001000
	.byte	%00001000
	.byte	%00001000
	.byte	%00001000
	.byte	%00001010


GRN12:
	.byte	%01000000		; Six pixel shift
	.byte	%01000000		; (2nd byte, reversed)
	.byte	%01000000
	.byte	%01000000
	.byte	%01000000
	.byte	%01000000
	.byte	%01000000
	.byte	%01000000

GRN13:
	.byte	%00101010		; Six pixel shift
	.byte	%00100000		; (reversed)
	.byte	%00100000
	.byte	%00100000
	.byte	%00100000
	.byte	%00100000
	.byte	%00100000
	.byte	%00101010

