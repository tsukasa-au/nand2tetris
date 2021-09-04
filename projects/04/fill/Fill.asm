// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input.
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel;
// the screen should remain fully black as long as the key is pressed.
// When no key is pressed, the program clears the screen, i.e. writes
// "white" in every pixel;
// the screen should remain fully clear as long as no key is pressed.

@is_black
M=0

(KEYBOARD_LOOP)

@KBD  // Keyboard
D=M
@ENSURE_WHITE  // No button, jump to loop.
D;JEQ

(ENSURE_BLACK)
@is_black
D=M
@KEYBOARD_LOOP
D;JNE  // If is_black is true, then there is nothing to do
@is_black
M=!M
@ARG
M=-1  // Set fill colour to Black
@FILL
0;JMP

(ENSURE_WHITE)
@is_black
D=M
@KEYBOARD_LOOP
D;JEQ  // If is_black is false, then there is nothing to do
@is_black
M=!M
@ARG
M=0  // Set fill colour to white
@FILL
0;JMP

(FILL)
// screen_addr is our pointer into the monitor.
// Set it to the start of the screen
@SCREEN
D=A
@screen_addr
M=D

// Set this pixel
(FILL_LOOP)
@ARG
D=M

// Perform the writes to the monitor
@screen_addr
A=M
M=D  // screen_addr[0]
A=A+1
M=D  // screen_addr[1]
A=A+1
M=D  // screen_addr[2]
A=A+1
M=D  // screen_addr[3]

D=A+1
@screen_addr
M=D  // screen_addr+=4
@24576  // Top of screen memory (0x6000)
D=D-A
@FILL_LOOP
D;JLT  // if D-0x6000 < 0
@KEYBOARD_LOOP
0;JMP
