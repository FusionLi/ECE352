.equ address, 0x00000

.global main

main:
	movia r5, address
	movi r6, 1
	sthio r6, 0(r5)
	movi r6, 2
	sthio r6, 2(r5)
	movi r6, 3
	sthio r6, 4(r5)
	movi r6, 4
	sthio r6, 6(r5)
	
	mov r10, r0
	mov r11, r0
	mov r12, r0
	mov r13, r0
	ldhio r10, 0(r5)
	ldhio r11, 2(r5)
	ldhio r12, 4(r5)
	ldhio r13, 6(r5)
END:
	br END
