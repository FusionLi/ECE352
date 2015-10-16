.equ JTAG 0xFF201000

.global main

main:
	movia r8, JTAG	# contain the base address
	mov r9, r0	# temp variable
	mov r10, r0	# temp variable
	mov r11, r0	# state variable for either change acceleration or change steering: 4->change acceleration, 5-> change steering and 0->no action
	mov r12, r0	# state variable for steering angle or acceleration
CONTROL:	# algorithm: one cycle can only make one change: either change acceleration or change direction
	call checkSensorAndSpeed
	beq r11, r0, CONTROL
	call changeDirectionOrSpeed
	br CONTROL

ChangeDirectionOrSpeed:
POLL_TYPE:
	ldwio r10, 4(r8)
	srli r10, r10, 16
	beq r10, r0, POLL
	stwio r11, 0(r8)
POLL_VALUE:
	ldwio r10, 4(r8)
	srli r10, r10, 16
	beq r10, r0, POLL_VALUE
	stwio r12, 0(r8)
	ret

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
	andi r10, r9, 0x01	# map outer left sensor
	beq r10, r0, RIGHT_STATE
	andi r10, r9, 0x80	# map outer right sensor
	beq r10, r0, LEFT_STATE
	mov r11, r0	# stay on current direction
READ_SPEED:
	ldwio r10, 0(r7) 
  	andi r9, r10, 0x8000
 	beq r9, r0, READ_SPEED
  	andi r9, r10, 0x00FF
	bne r11, r0, RETURN	# judge whether if already assigned a state
	movi r10, 127	# max speed
	bgt r9, r10, DECELERATION_STATE
	blt r9, r10, ACCELERATION_STATE
	mov r11, r0	# stay on current speed
RETURN:
	ret

LEFT_STATE:
	movi r11, 0x05
	movi r12, 20	# turn left angle
	br READ_SPEED
RIGHT_STATE:
	movi r11, 0x05
	movi r12, -20	# turn right angle
	br READ_SPEED
DECELERATION_STATE:
	movi r11, 0x04
	movi r12, -60	# deceleration value
	br RETURN
ACCELERATION_STATE:
	movi r11, 0x04
	movi r12, 60	# acceleration value
	br RETURN		
