.global main

.equ ADDR_JP1, 0x10000060   # Address GPIO JP1
.equ TIMER, 0xff202000

# Assume we are using motor0 and sensor0 and sensor1
# sensor0 is at left and sensor1 is at right 

main: 
	movia r8, ADDR_JP1
	movia r9, 0x07f557ff # set direction for motors to all output 
	stwio r9, 4(r8)

	movia r2, TIMER
	movui r2, 5000 # period is 5000 cycles
   	stwio r2, 8(r2) # Set the period to be 1000 clock cycles
   	stwio r0, 12(r2)

FIRST:
	movia r9, 0xffffebff  # enable sensor0 and sensor1 and disable motor0
	stwio r9, 0(r8)
	ldwio r5, 0(r8)
	srli r5, r5, 11
	andi r5, r5, 0x1 # map ready sensor0_bit
	bne r5, r0, FIRST
	ldwio r10, 0(r8)
	srli r10, r10, 27
	andi r10,15 r10, 0xf # value of sensor0
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
	call delay
	movia r9, 0xffffffff # stop motor
	stwio r9, 0(r8)
	call delay
	br FIRST

RIGHT:
	movia r9, 0xfffffffe # rotate clockwise
	stwio r9, 0(r8)
	call delay
	movia r9, 0xffffffff # stop motor
	stwio r9, 0(r8)
	call delay
	br FIRST	

delay:
	movui r2, 4 # start counter
   	stwio r2, 4(r2)
POLLING:
	ldwio r3, 0(r2)
	andi r3, r3, 0x1
	beq r3, r0, POLLING # check TO bit
	movi r3, 0
	stwio, r3, 0(r2) # reset TO bit 
	ret
