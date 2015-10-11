.global main

.equ ADDR_JP1, 0x10000060   # Address GPIO JP1

# Assume we are using motor0 and sensor0 and sensor1
# sensor0 is at left and sensor1 is at right 

main: 
	movia r8, ADDR_JP1
	movia r9, 0x07f557ff # set direction for motors to all output
	stwio r9, 4(r8)

FIRST:
	movia r9, 0xffffebff  # enable sensor0 and sensor1 and disable motor0
	stwio r9, 0(r8)
	ldwio r5, 0(r8)
	srli r5, r5, 11
	andi r5, r5, 0x1 # map ready sensor0_bit
	bne r5, r0, FIRST
	ldwio r10, 0(r8)
	srli r10, r10, 27
	andi r10, r10, 0xf # value of sensor0
SECOND:
	ldwio r5, 0(r8)
	srli r5, r5, 13
	andi r5, r5, 0x1 # map ready sensor1_bit
	bne r5, r0, SECOND	
	ldwio r11, 0(r8)
	srli r11, r11, 27
	andi r11, r11, 0xf # value of sensor1
	sub r12, r10, r11 # difference between sensor0 and sensor1
	movi r13, 10 # upper threshold
	bgt r12, r13, LEFT
	movi r13, -10 # lower threshold
	blt r12, r13, RIGHT
	br FIRST

LEFT: 
	movia r9, 0xfffffffc # rotate counterclockwise
	stwio r9, 0(r8)
	br FIRST

RIGHT:
	movia r9, 0xfffffffe # rotate clockwise
	stwio r9, 0(r8)
	br FIRST	
