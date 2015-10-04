# Print ten in octal, hexadecimal, and decimal
# Use the following C functions:
#     printHex ( int ) ;
#     printOct ( int ) ;
#     printDec ( int ) ;

.global main

main:

movi r4, 10
addi sp, sp, -4
stw ra, 0(sp)
call printn
ldw ra, 0(sp)
addi sp, sp ,4
END:
br END

printn:
call printOct
call printHex
call printDec
ret
