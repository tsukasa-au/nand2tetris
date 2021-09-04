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
@2
M=0

// Load R1 into a temporary (this is our counter that we will decrement)
@1
D=M
@mul_remaining
M=D
@DONE
D;JLE // if mul_remaining <= 0; jump DONE // No more iterations required

(LOOP)

// Perform one step: (R2 += R0)
@0
D=M
@2
M=D+M
@mul_remaining
M=M-1
D=M
@LOOP
D;JGT  // If mul_remaining > 0; jump LOOP

(DONE)

(END)
@END
0;JMP
