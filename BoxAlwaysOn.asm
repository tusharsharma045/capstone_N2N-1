// BoxAlwaysOn.asm — Test file: Box is drawn in black immediately
(LOOP)
    @color
    M=-1            // Always black

    // --- RENDER ---
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
    @LOOP
    D;JEQ

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
    M=D

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
