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

// Load R1 into a temporary (this is our counter that we will decrement)
@R1
D=M

// Handle the case where R1 is not divisible by 8
@8
D=A-D
@7
D=D&A
@PRE_LOOP
D;JLE  // If R0 % 8 == 0; jump PRE_LOOP
A=D
D=D+A
@MUL_UNROLL
A=A+D
D=0;JMP
(MUL_UNROLL)
@R0
D=D+M
@R0
D=D+M
@R0
D=D+M
@R0
D=D+M
@R0
D=D+M
@R0
D=D+M
@R0
D=D+M
@R0
D=D+M

@R2
M=D

(PRE_LOOP)
@R1
D=M
@7
A=!A
D=D&A
@mul_remaining
M=D
@DONE
D;JLE // if mul_remaining <= 0; jump DONE // No more iterations required

(LOOP)

// Perform one step: (R2 += R0)
@R0
AD=M    // D = R0
AD=D+A  // D = 2*R0
AD=D+A  // D = 4*R0
AD=D+A  // D = 8*R0
@R2
M=D+M  // R2 += 8*R0
@8
D=A
@mul_remaining
MD=M-D  // mul_remaining -= 4
@LOOP
D;JGT  // If mul_remaining > 0; jump LOOP

@DONE
(DONE)
0;JMP
