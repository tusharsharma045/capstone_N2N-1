// BoxOnce.asm — Press any key ONCE -> Box appears and stays permanently
(WAIT_KEY)
    @KBD
    D=M
    @DRAW_BOX
    D;JNE           // If key pressed (D != 0), jump to DRAW_BOX
    @WAIT_KEY
    0;JMP           // Wait until key is pressed

(DRAW_BOX)
    @color
    M=-1            // Black

    @20
    D=A
    @rows
    M=D

    @SCREEN
    D=A
    @704
    D=D+A
    @addr
    M=D

(ROWLOOP)
    @rows
    D=M
    @HALT
    D;JEQ           // When all 20 rows are drawn, stop

    @3
    D=A
    @cols
    M=D

    @addr
    D=M
    @rowaddr
    M=D

(COLLOOP)
    @cols
    D=M
    @NEXTROW
    D;JEQ

    @color
    D=M
    @rowaddr
    A=M
    M=D             // Paint word black

    @rowaddr
    M=M+1
    @cols
    M=M-1
    @COLLOOP
    0;JMP

(NEXTROW)
    @32
    D=A
    @addr
    M=D+M
    @rows
    M=M-1
    @ROWLOOP
    0;JMP

(HALT)
    @HALT
    0;JMP           // Infinite idle loop: keeps box on screen permanently!
