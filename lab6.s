.equ JTAG 0x10001020
.equ KEYBOARD 0xFF201000
.equ TIMER 0xFF202000

.section .exceptions, "ax"	# interrupt handler
.align 2

HANDLER:	# no need to use PROLOGUE
	ldw r4, 4(r2)
	andi r4, r4, 0x100	# map out bit8 (read interrupt pending bit of keyboard)
	bne r4, r0, KEYBOARD_IRQ
	ldw r4, 0(r3)
	andi r4, r4, 0x1	# map out bit0 (timeout bit of timer)
	beq r4, r0, EPILOGUE
	call erase
	call print
	stw r0, 0(r3)	# reset timeout bit
	br EPILOGUE
	
KEYBOARD_IRQ:
	ldwio r4, 0(r2)
	andi r4, r4, 0xff	# map out the character received
	movi r5, 'r'
	beq r4, r5, R_PRESSED
	movi r5, 's'
	beq r4, r5, S_PRESSED

R_PRESSED:	# 'r' should not be pressed twice successively due to offset of sp
	call erase
	addi sp, sp, 4	# change sp position to sensor value
	call print
	br EPILOGUE
S_PRESSED:	# 's' should be pressed only when 'r' has been pressed and it should not be pressed twice successively due to offset of sp
	call erase
	subi sp, sp, 4	# change sp position to speed value
	call print
	br EPILOGUE

EPILOGUE:
	subi ea, ea, 4
	eret

erase:
	movi r4, 0x1b
	stwio r4, 0(r2)
	movi r4, '['
	stwio r4, 0(r2)
	movi r4, '2'
	stwio r4, 0(r2)
	movi r4, 'K'
	stwio r4, 0(r2)
	ret

print:
	ldw r4, 0(sp)	# read either speed value or sensor value
	stwio r4, 0(r2)	# print the value on the terminal window
	ret
	
	
.text	0x00000420	# offset

.global main

main:
	movia r8, JTAG	# contain the base address of CarWorld
	mov r5, r0	# temp variable
	mov r9, r0	# temp variable
	mov r10, r0	# temp variable
	mov r11, r0	# state variable change acceleration and change steering (bit0-15 is for speed change and bit16-31 is for direction change): 4->change acceleration, 5-> change direction and 0->no action
	mov r12, r0	# state variable for steering angle and acceleration (bit0-15: acceleration and bit16-31: angle)
	mov r13, 40	# max speed
	mov r14, r0	# temp variable
	subi sp, sp, 8	# reserve space for speed value and sensor value for interrupt to read

TIMER_SETTING:	# period is 50000000 cycles = 1 sec = 0x02faf080
	movia r3, TIMER
	ori r4, r0, 0xf080
	stwio, r4, 8(r3)	# lower half period
	ori r4, r0, 0x02fa
	stwio r4, 12(r3)	# upper half period
	movi r4, 0x4
	stwio r4, 4(r3)	# start the timer
INTERRUPT:
	movia r2, KEYBOARD	
	movi r4, 0x1
	stwio r4, 4(r2)	# enable read interrupt on keyboard
	stwio r4, 4(r3)	# enable timeout interrupt on timer
	movi r4, 0x101	
	wrctl ctl3, r4	# enable IRQ8 for keyboard and IRQ0 for timer
	movi r4, 0x1
	wrctl ctl1, r4	# tell cpu to accept interrupts

CONTROL:	# algorithm: without using position
	call checkSensorAndSpeed
	beq r11, r0, CONTROL
	call changeDirectionAndSpeed
	br CONTROL

ChangeDirectionAndSpeed:
CHANGE:
andi r9, r11, 0xffff	# map out state
andi r14, r12, 0xffff	# map out value
POLL_TYPE:
	ldwio r10, 4(r8)
	srli r10, r10, 16
	beq r10, r0, POLL
	stwio r9, 0(r8)
POLL_VALUE:
	ldwio r10, 4(r8)
	srli r10, r10, 16
	beq r10, r0, POLL_VALUE
	stwio r14, 0(r8)
	movi r9, 0x04
	srli r12, 16
	beq r11, r9, NO_STEERING	# whether it is only a change speed state
	srli r11, 16
	bne r11, r0, CHANGE	# check whether it has two instructions
	ret

ON_STEERING:
	movi r11, 0x05
	br CHANGE	

checkSensroAndSpeed:
WRITE_POLL:
	ldwio r10, 4(r8) 
  	srli r10, r10, 16 
  	beq r10, r0, WRITE_POLL 
  	movi r10, 0x02 
  	stwio r10, 0(r7) 
READ_TYPE:
	ldwio r10, 0(r7) 
  	andi r9, r10, 0x8000
 	beq r9, r0, READ_TYPE
  	andi r9, r10, 0x00FF
	bne r9, r0, READ_TYPE	# should not happen
READ_SENSOR:
	ldwio r10, 0(r7) 
  	andi r9, r10, 0x8000
 	beq r9, r0, READ_SENSOR
  	andi r9, r10, 0x00FF
	stw r9, 4(sp)	# ready for interrupt to read sensor values
	andi r10, r9, 0x01	# map out left sensor
	beq r10, r0, RIGHT_STATE
	andi r10, r9, 0x80	# map out right sensor
	beq r10, r0, LEFT_STATE
	mov r11, r0	# stay on current direction
READ_SPEED:
	ldwio r10, 0(r7) 
  	andi r9, r10, 0x8000
 	beq r9, r0, READ_SPEED
  	andi r9, r10, 0x00FF
	stw r9, 0(sp)	# ready for interrupt to read speed value
	bne r11, r0, STEERING_MODE	# judge whether if the car is in steering mode
SPEED_JUDGE:
	bgt r9, r13, DECELERATION_STATE
	blt r9, r13, ACCELERATION_STATE
	ret

STEERING_MODE:
	movi r13, 20	# set turning speed 
	slli r11, 16	# make space for next state
	slli r12, 16	# make space for acceleration value	
	ori r11, r11, 0x04	# it has to have two states
	br SPEED_JUDGE

LEFT_STATE:
	ori r11, r11, 0x05
	ori r12, r12, -127	# turn left angle
	br READ_SPEED
RIGHT_STATE:
	ori r11, r11, 0x05
	ori r12, r12, 127	# turn right angle
	br READ_SPEED
DECELERATION_STATE:
	ori r11, r11, 0x04
	ori r12, r12, -60	# deceleration value
	br RETURN
ACCELERATION_STATE:
	ori r11, r11, 0x04
	ori r12, r12, 60	# acceleration value
	br RETURN		

