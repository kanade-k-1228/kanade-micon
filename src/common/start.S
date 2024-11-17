#include "custom_ops.S"

///////////////////////////////////////

.section .data

///////////////////////////////////////
// Memory for IRQ Handler

irq_regs:
	.fill 32,4

	.fill 128,4
irq_stack:

///////////////////////////////////////

.section .text

///////////////////////////////////////
// Reset
// no more than 16 bytes here !

reset_vec:
	//picorv32_waitirq_insn(zero)
	//picorv32_maskirq_insn(zero, zero)
	j start

///////////////////////////////////////
// Interrupt Handler

.balign 16 // picorv32.PROGADDR_IRQ
irq_vec:

// Current state
//
// pc = 0x0500_0010
// q0 = interrupt return address
// q1 = irq bits

// Save Registers

	// irq_regs q2 & q3 is reserved for saving registers
	// q2 & q3 must save values during irq function
	picorv32_setq_insn(q2, x1) // q2 <= x1 (ra)
	picorv32_setq_insn(q3, x2) // q3 <= x2 (sp)
	// now x1 & x2 is free

// Disable interrupt

	// lui  x1,     %hi(0xFFFFFFFF)
	// addi x1, x1, %lo(0xFFFFFFFF)
	// picorv32_maskirq_insn(zero,x1)

// Save Registers

	lui  x1,     %hi(irq_regs)
	addi x1, x1, %lo(irq_regs)

    picorv32_getq_insn(x2, q0)
	sw x2,   0*4(x1) // irq_regs + 00 <= interrut return address
	picorv32_getq_insn(x2, q2)
	sw x2,   1*4(x1) // irq_regs + 04 <= original x1 (ra)
	picorv32_getq_insn(x2, q3)
	sw x2,   2*4(x1) // irq_regs + 08 <= original x2 (sp)

	sw x3,   3*4(x1) // irq_regs + 0C <=  x3
	sw x4,   4*4(x1) // irq_regs + 10 <=  x4
	sw x5,   5*4(x1) // irq_regs + 14 <=  x5
	sw x6,   6*4(x1) // irq_regs + 18 <=  x6
	sw x7,   7*4(x1) // irq_regs + 1C <=  x7
	sw x8,   8*4(x1) // irq_regs + 20 <=  x8
	sw x9,   9*4(x1) // irq_regs + 24 <=  x9
	sw x10, 10*4(x1) // irq_regs + 28 <= x10
	sw x11, 11*4(x1) // irq_regs + 2C <= x11
	sw x12, 12*4(x1) // irq_regs + 30 <= x12
	sw x13, 13*4(x1) // irq_regs + 34 <= x13
	sw x14, 14*4(x1) // irq_regs + 38 <= x14
	sw x15, 15*4(x1) // irq_regs + 3C <= x15
	sw x16, 16*4(x1) // irq_regs + 40 <= x16
	sw x17, 17*4(x1) // irq_regs + 44 <= x17
	sw x18, 18*4(x1) // irq_regs + 48 <= x18
	sw x19, 19*4(x1) // irq_regs + 4C <= x19
	sw x20, 20*4(x1) // irq_regs + 50 <= x20
	sw x21, 21*4(x1) // irq_regs + 54 <= x21
	sw x22, 22*4(x1) // irq_regs + 58 <= x22
	sw x23, 23*4(x1) // irq_regs + 5C <= x23
	sw x24, 24*4(x1) // irq_regs + 60 <= x24
	sw x25, 25*4(x1) // irq_regs + 64 <= x25
	sw x26, 26*4(x1) // irq_regs + 68 <= x26
	sw x27, 27*4(x1) // irq_regs + 6C <= x27
	sw x28, 28*4(x1) // irq_regs + 70 <= x28
	sw x29, 29*4(x1) // irq_regs + 74 <= x29
	sw x30, 30*4(x1) // irq_regs + 78 <= x30
	sw x31, 31*4(x1) // irq_regs + 7C <= x31

// call C function
// irq(
//    arg0 = pointer to saved registers
//    arg1 = interrupt type bitmask
// )

.global irq

	// irq function use irq_stack
	lui  sp,     %hi(irq_stack)
	addi sp, sp, %lo(irq_stack)

	// set arg0
	lui  a0,     %hi(irq_regs)
	addi a0, a0, %lo(irq_regs)

	// set arg1
	picorv32_getq_insn(a1, q1)

	jal ra, irq

/////////////////////////////////////
// return irq
// ret a0 = new irq_regs address

	mv x1, a0

// restore registers

	lw x2,   0*4(x1)
	picorv32_setq_insn(q0, x2)

	lw x2,   1*4(x1)
	picorv32_setq_insn(q2, x2)

	lw x2,   2*4(x1)
	picorv32_setq_insn(q3, x2)

	lw x3,   3*4(x1)
	lw x4,   4*4(x1)
	lw x5,   5*4(x1)
	lw x6,   6*4(x1)
	lw x7,   7*4(x1)
	lw x8,   8*4(x1)
	lw x9,   9*4(x1)
	lw x10, 10*4(x1)
	lw x11, 11*4(x1)
	lw x12, 12*4(x1)
	lw x13, 13*4(x1)
	lw x14, 14*4(x1)
	lw x15, 15*4(x1)
	lw x16, 16*4(x1)
	lw x17, 17*4(x1)
	lw x18, 18*4(x1)
	lw x19, 19*4(x1)
	lw x20, 20*4(x1)
	lw x21, 21*4(x1)
	lw x22, 22*4(x1)
	lw x23, 23*4(x1)
	lw x24, 24*4(x1)
	lw x25, 25*4(x1)
	lw x26, 26*4(x1)
	lw x27, 27*4(x1)
	lw x28, 28*4(x1)
	lw x29, 29*4(x1)
	lw x30, 30*4(x1)
	lw x31, 31*4(x1)

// Restore registers

	picorv32_getq_insn(x1, q2)
	picorv32_getq_insn(x2, q3)

// Enable interrupt

	// picorv32_maskirq_insn(zero,zero)

// return from irq
	
	picorv32_retirq_insn()

///////////////////////////////////////
// Main program

start:

// zero-initialize all registers 

	addi x1, zero, 0
	// x2 = sp is initialize to picorv32.STACKADDR
	addi x3, zero, 0
	addi x4, zero, 0
	addi x5, zero, 0
	addi x6, zero, 0
	addi x7, zero, 0
	addi x8, zero, 0
	addi x9, zero, 0
	addi x10, zero, 0
	addi x11, zero, 0
	addi x12, zero, 0
	addi x13, zero, 0
	addi x14, zero, 0
	addi x15, zero, 0
	addi x16, zero, 0
	addi x17, zero, 0
	addi x18, zero, 0
	addi x19, zero, 0
	addi x20, zero, 0
	addi x21, zero, 0
	addi x22, zero, 0
	addi x23, zero, 0
	addi x24, zero, 0
	addi x25, zero, 0
	addi x26, zero, 0
	addi x27, zero, 0
	addi x28, zero, 0
	addi x29, zero, 0
	addi x30, zero, 0
	addi x31, zero, 0

	call main

loop:
	j loop
