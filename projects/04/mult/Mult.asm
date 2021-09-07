// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Mult.asm

// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)
//
// This program only needs to handle arguments that satisfy
// R0 >= 0, R1 >= 0, and R0*R1 < 32768.

// Put your code here.

// Clear the result
@R2
M=0

@mul_test
M=1
@R1
D=M
@shifted_r1
M=D

(LOOP)

@mul_test
D=M
@R0
D=D&M
@LOOP_AFTER_ADD
D;JEQ  // This bit in R0 is a zero, so we don't need to add shifted_r1.
@shifted_r1
D=M
@R2
M=D+M
(LOOP_AFTER_ADD)

// Shift the value in R1 right by 1 bit
@shifted_r1
AD=M
D=D+A
@shifted_r1
M=D

// Shift the value in mul_test right by 1 bit
@mul_test
AD=M
D=D+A
@mul_test
M=D

@LOOP
D;JNE  // If we have bits remaining

@DONE
(DONE)
0;JMP
