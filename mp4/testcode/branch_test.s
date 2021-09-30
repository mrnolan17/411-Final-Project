#  mp4-cp2.s version 1.3
.align 4
.section .text
.globl _start
_start:

#   Your pipeline should be able to do hazard detection and forwarding.
#   Note that you should not stall or forward for dependencies on register x0 or when an
#   instruction does not use one of the source registers (such as rs2 for immediate instructions).

# Mispredict taken branch flushing tests
    li x1, 255

taken_branches:

    add x1, x1, -1				
    bge x1, x0, taken_branches
    and x3, x3, 0
    and x2, x2, 0
    and x1, x1, 0
    li x3, 255
    li x2, 1
    li x1, -1

branch_two:
    bge x3, x2, positive
    ble x3, x1, negative

    beq x3, x0, done                    # Also, test back-to-back branches

positive: 
    not x3, x3
    add x3, x3, 2
    j branch_two

negative:
    not x3, x3
    add x3, x3, 0
    j branch_two

done:
    j done




.section .rodata
.balign 256
DataSeg:
    nop
    nop
    nop
    nop
    nop
    nop
BAD:            .word 0x00BADBAD
PAY_RESPECTS:   .word 0xFFFFFFFF
# cache line boundary - this cache line should never be loaded

A:      .word 0x00000001
GOOD:   .word 0x600D600D
NOPE:   .word 0x00BADBAD
TEST:   .word 0x00000000
FULL:   .word 0xFFFFFFFF
        nop
        nop
        nop
# cache line boundary

B:      .word 0x00000002
        nop
        nop
        nop
        nop
        nop
        nop
        nop
# cache line boundary

C:      .word 0x00000003
        nop
        nop
        nop
        nop
        nop
        nop
        nop
# cache line boundary

D:      .word 0x00000004
        nop
        nop
        nop
        nop
        nop
        nop
        nop
