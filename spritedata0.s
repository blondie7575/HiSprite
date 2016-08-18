;
;  spritedata.s
;
;  Created by Quinn Dunki on 7/19/16
;  Copyright (c) 2015 One Girl, One Laptop Productions. All rights reserved.
;

MAG0:
	.byte	%01010101		; Byte aligned
	.byte	%01000001		; (reversed)
	.byte	%01000001
	.byte	%01000001		;;;;;;;;;;;;;;;;;;;;
	.byte	%01000001
	.byte	%01000001
	.byte	%01000001
	.byte	%01010101

MAG1:
	.byte	%00000000		; Byte aligned
	.byte	%00000000		; (2nd byte, reversed)
	.byte	%00000000
	.byte	%00000000
	.byte	%00000000
	.byte	%00000000
	.byte	%00000000
	.byte	%00000000

MAG2:
	.byte	%01010100		; One pixel shift
	.byte	%00000100		; (reversed)
	.byte	%00000100
	.byte	%00000100
	.byte	%00000100
	.byte	%00000100
	.byte	%00000100
	.byte	%01010100

MAG3:
	.byte	%00000010		; One pixel shift
	.byte	%00000010		; (2nd byte, reversed)
	.byte	%00000010
	.byte	%00000010
	.byte	%00000010
	.byte	%00000010
	.byte	%00000010
	.byte	%00000010


MAG4:
	.byte	%01010000		; Two pixel shift
	.byte	%00010000		; (reversed)
	.byte	%00010000
	.byte	%00010000
	.byte	%00010000
	.byte	%00010000
	.byte	%00010000
	.byte	%01010000

MAG5:
	.byte	%00001010		; Two pixel shift
	.byte	%00001000		; (2nd byte, reversed)
	.byte	%00001000
	.byte	%00001000
	.byte	%00001000
	.byte	%00001000
	.byte	%00001000
	.byte	%00001010


MAG6:
	.byte	%01000000		; Three pixel shift
	.byte	%01000000		; (reversed)
	.byte	%01000000
	.byte	%01000000
	.byte	%01000000
	.byte	%01000000
	.byte	%01000000
	.byte	%01000000

MAG7:
	.byte	%00101010		; Three pixel shift
	.byte	%00100000		; (2nd byte, reversed)
	.byte	%00100000
	.byte	%00100000
	.byte	%00100000
	.byte	%00100000
	.byte	%00100000
	.byte	%00101010


MAG8:
	.byte	%00101010		; Four pixel shift
	.byte	%00000010		; (reversed)
	.byte	%00000010
	.byte	%00000010
	.byte	%00000010
	.byte	%00000010
	.byte	%00000010
	.byte	%00101010

MAG9:
	.byte	%00000001		; Four pixel shift
	.byte	%00000001		; (2nd byte, reversed)
	.byte	%00000001
	.byte	%00000001
	.byte	%00000001
	.byte	%00000001
	.byte	%00000001
	.byte	%00000001


MAG10:
	.byte	%00101000		; Five pixel shift
	.byte	%00001000		; (reversed)
	.byte	%00001000
	.byte	%00001000
	.byte	%00001000
	.byte	%00001000
	.byte	%00001000
	.byte	%00101000

MAG11:
	.byte	%00000101		; Five pixel shift
	.byte	%00000100		; (2nd byte, reversed)
	.byte	%00000100
	.byte	%00000100
	.byte	%00000100
	.byte	%00000100
	.byte	%00000100
	.byte	%00000101


MAG12:
	.byte	%00100000		; Six pixel shift
	.byte	%00100000		; (2nd byte, reversed)
	.byte	%00100000
	.byte	%00100000
	.byte	%00100000
	.byte	%00100000
	.byte	%00100000
	.byte	%00100000

MAG13:
	.byte	%00010101		; Six pixel shift
	.byte	%00010000		; (reversed)
	.byte	%00010000
	.byte	%00010000
	.byte	%00010000
	.byte	%00010000
	.byte	%00010000
	.byte	%00010101


BLACK:
	.byte	%00000000
	.byte	%00000000
	.byte	%00000000
	.byte	%00000000
	.byte	%00000000
	.byte	%00000000
	.byte	%00000000
	.byte	%00000000
