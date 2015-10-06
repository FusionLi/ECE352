/*********
 * 
 * Write the assembly function:
 *     printn ( char * , ... ) ;
 * Use the following C functions:
 *     printHex ( int ) ;
 *     printOct ( int ) ;
 *     printDec ( int ) ;
 * 
 * Note that 'a' is a valid integer, so movi r2, 'a' is valid, and you don't need to look up ASCII values.
 *********/

.global	printn
printn:
// 3 print case	
movi r13, O
movi r14, H
movi r15, D
// r8 is temp variable for current number to be printed
INITIAL:
mov r9, sp
// first three arguments saved in register r3-r7
ldw r8, 0(r4)
mov r10, r5
// save everything on temp variable
mov r11, ra
mov r12, r4
beq r8, r0 END
call JUDGE
// restore back
mov ra, r11
mov r4, r12
addi r4, r4, 1
ldw r8, 0(r4)
mov r10, r6
// save everything on temp variable
mov r11, ra
mov r12, r4
beq r8, r0 END
call JUDGE
// restore back
mov ra, r11
mov r4, r12
addi r4, r4, 1
ldw r8, 0(r4)
mov r10, r7
// save everything on temp variable
mov r11, ra
mov r12, r4
beq r8, r0 END
call JUDGE
// restore back
mov ra, r11
mov r4, r12
beq r8, r0 END
addi r4, r4, 1
// processing the arguments after r7
LOOP:
ldw r8, 0(r4)
ldw r10, 0(sp)
mov r11, ra
mov r12, r4
call JUDGE
mov ra, r11
mov r4, r12
beq r8, r0 END
addi r4,r4,1
addi sp,sp,4

JUDGE:
beq r8 r13, OCT
beq r8, r14, HEX
beq r8, r15, DEC
END_JUDGE:
ret

OCT:
mov r4, r10
call printOct
br END_JUDGE
HEX:
mov r4, r10
call printHex
br END_JUDGE
DEC:
mov r4, r10
call printDec
br END_JUDGE

END:
mov sp, r9
ret
