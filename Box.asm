// ============================================================================
// Box.asm — Interactive State-Driven Box Program for Hack Computer
// ============================================================================
// Roll Number : 2501730122
// K Value     : 22  (last two digits of roll number)
//
// Box Parameters (derived from K = 22):
//   - Starting row    : Row 22
//   - Box height      : 20 rows (Rows 22 through 41)
//   - Box width       : 16 * ((22 mod 4) + 1) = 16 * 3 = 48 pixels (3 words)
//   - Screen Address  : 16384 + (32 * 22) = 17088 (SCREEN + 704)
//
// State-Driven Behaviour:
//   1. Waits in idle loop until ANY key is pressed.
//   2. Once key pressed  -> Instantly paints 48x20 solid BLACK box at Row 22.
//   3. Holds solid black -> Waits until the key is released.
//   4. Once key released -> Instantly erases box (paints WHITE).
//   5. Loops back to step 1.
// ============================================================================

// ----------------------------------------------------------------------------
// STATE 1: Wait for a key to be pressed
// ----------------------------------------------------------------------------
(WAIT_PRESS)
    @24576          // Keyboard memory address (KBD)
    D=M             // Read scan code
    @DRAW_BLACK
    D;JNE           // If key is pressed (D != 0), jump to draw black box
    @WAIT_PRESS
    0;JMP           // Otherwise, keep waiting (idle)

// ----------------------------------------------------------------------------
// Triggered on key press: Set color to black (-1) and render
// ----------------------------------------------------------------------------
(DRAW_BLACK)
    @color
    M=-1            // -1 in two's complement = 1111111111111111 (Black)
    @RENDER
    0;JMP

// ----------------------------------------------------------------------------
// STATE 2: Wait for the key to be released
// ----------------------------------------------------------------------------
(WAIT_RELEASE)
    @24576          // Keyboard memory address (KBD)
    D=M             // Read scan code
    @DRAW_WHITE
    D;JEQ           // If key is released (D == 0), jump to erase box
    @WAIT_RELEASE
    0;JMP           // Keep holding black box until key is released

// ----------------------------------------------------------------------------
// Triggered on key release: Set color to white (0) and render
// ----------------------------------------------------------------------------
(DRAW_WHITE)
    @color
    M=0             // 0 = 0000000000000000 (White / erase)
    @RENDER
    0;JMP

// ----------------------------------------------------------------------------
// RENDER KERNEL: Paints the 48x20 rectangle starting at Row 22
// ----------------------------------------------------------------------------
(RENDER)
    @17088          // Base screen address: 16384 + 32 * 22 = 17088
    D=A
    @addr
    M=D             // addr = 17088

    @20             // Box height: 20 rows
    D=A
    @rows
    M=D

(ROWLOOP)
    @3              // Box width: 3 words (48 pixels)
    D=A
    @cols
    M=D

(COLLOOP)
    @color
    D=M
    @addr
    A=M
    M=D             // Screen[addr] = color

    @addr
    M=M+1           // Advance to next word in row

    @cols
    M=M-1
    D=M
    @COLLOOP
    D;JGT           // Loop for all 3 words in this row

    // Finished row: jump 29 words ahead (32 - 3 = 29) to reach next row
    @29
    D=A
    @addr
    M=D+M

    @rows
    M=M-1
    D=M
    @ROWLOOP
    D;JGT           // Loop for all 20 rows

    // State transition after render:
    // If color was black (-1), wait for key release
    // If color was white (0), wait for key press
    @color
    D=M
    @WAIT_RELEASE
    D;JNE
    @WAIT_PRESS
    0;JMP
