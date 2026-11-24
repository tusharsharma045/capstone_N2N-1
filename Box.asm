// ============================================================================
// Box.asm — Interactive Box Drawing Program for the Hack Computer
// ============================================================================
// Roll Number : 2501730122
// K Value     : 22  (last two digits of roll number)
//
// Box Parameters (derived from K = 22):
//   - Starting row    : row 22
//   - Box height      : 20 rows (rows 22 through 41)
//   - Box width       : 16 × ((K mod 4) + 1) = 16 × ((22 mod 4) + 1)
//                      = 16 × (2 + 1) = 16 × 3 = 48 pixels = 3 words
//   - Box position    : left edge of the screen (words 0, 1, 2 in each row)
//
// Behaviour:
//   - When ANY key is held down  → the box is drawn in BLACK (filled)
//   - When NO key is pressed     → the box is ERASED (cleared to white)
//   - The program loops forever, continuously checking the keyboard.
//
// ============================================================================
// How the Hack Screen Memory Map Works:
// ============================================================================
//   • The screen is 256 rows × 512 pixels (columns).
//   • Each pixel is either black (1) or white (0).
//   • The screen's memory-mapped I/O begins at address 16384 (label: SCREEN).
//   • Each row of 512 pixels is stored in 32 consecutive 16-bit words
//     (because 512 pixels ÷ 16 bits/word = 32 words/row).
//   • So the word at address SCREEN + (32 × row) + col_word controls
//     16 pixels starting at column (col_word × 16).
//   • Writing -1 (all sixteen bits = 1) to a word turns those 16 pixels BLACK.
//   • Writing  0 (all sixteen bits = 0) to a word turns those 16 pixels WHITE.
//
//   • The keyboard is memory-mapped at address 24576 (label: KBD).
//     If a key is currently pressed, KBD contains its scan code (≠ 0).
//     If no key is pressed, KBD contains 0.
//
// Our box starts at:  SCREEN + 32 × 22 = SCREEN + 704
// ============================================================================
// Variables used (stored in RAM):
//   color   — the value to paint: -1 for black, 0 for white
//   rows    — counts down from 20 to 0 (one per row of the box)
//   cols    — counts down from 3 to 0 (one per word/column in a row)
//   addr    — the screen address of the START of the current row
//   rowaddr — the screen address of the current word being painted
// ============================================================================

// =====================
// MAIN LOOP — runs forever, polling the keyboard each iteration
// =====================
(LOOP)
    @KBD            // A = 24576 (keyboard memory-mapped address)
    D=M             // D = current keyboard value (0 if no key, else scan code)

    @SETBLACK       // prepare to jump to SETBLACK label
    D;JNE           // if D ≠ 0 (a key IS pressed), jump to SETBLACK

    // --- No key is pressed: set color to white (erase the box) ---
    @color          // A = address of variable 'color'
    M=0             // color = 0 (white — all bits off)

    @RENDER         // prepare to jump to RENDER
    0;JMP           // unconditional jump to RENDER (begin drawing/erasing)

// =====================
// SETBLACK — a key is pressed, so we want to draw the box in black
// =====================
(SETBLACK)
    @color          // A = address of variable 'color'
    M=-1            // color = -1 (black — all 16 bits set to 1)
                    // In two's complement, -1 = 1111111111111111 in binary

// Fall through into RENDER (no jump needed — RENDER is the next label)

// =====================
// RENDER — set up the row counter and starting screen address, then draw
// =====================
(RENDER)
    // --- Initialise the row counter to 20 (box is 20 rows tall) ---
    @20             // A = 20
    D=A             // D = 20
    @rows           // A = address of variable 'rows'
    M=D             // rows = 20

    // --- Calculate the screen address where the box begins ---
    //     Starting address = SCREEN + 32 × 22 = SCREEN + 704
    @SCREEN         // A = 16384 (base address of screen memory)
    D=A             // D = 16384
    @704            // A = 704  (offset: 32 words/row × 22 rows)
    D=D+A           // D = 16384 + 704 = 17088 (first word of row 22)
    @addr           // A = address of variable 'addr'
    M=D             // addr = 17088 (screen address of row 22, word 0)

// =====================
// ROWLOOP — iterate over each of the 20 rows
// =====================
(ROWLOOP)
    @rows           // A = address of 'rows'
    D=M             // D = current value of rows (counts down from 20)
    @LOOP           // prepare to jump back to LOOP (keyboard check)
    D;JEQ           // if rows == 0, all rows are done → jump to LOOP

    // --- Initialise the column counter to 3 (box is 3 words wide) ---
    @3              // A = 3
    D=A             // D = 3
    @cols           // A = address of variable 'cols'
    M=D             // cols = 3

    // --- Save the start-of-row address into rowaddr ---
    //     (rowaddr will be incremented word by word across the row)
    @addr           // A = address of 'addr'
    D=M             // D = current row's starting screen address
    @rowaddr        // A = address of variable 'rowaddr'
    M=D             // rowaddr = addr (copy the row start address)

// =====================
// COLLOOP — iterate over the 3 words (48 pixels) within the current row
// =====================
(COLLOOP)
    @cols           // A = address of 'cols'
    D=M             // D = remaining columns to fill
    @NEXTROW        // prepare to jump to NEXTROW
    D;JEQ           // if cols == 0, this row is fully painted → next row

    // --- Write the color value into the current screen word ---
    @color          // A = address of 'color'
    D=M             // D = color (-1 for black, 0 for white)

    @rowaddr        // A = address of 'rowaddr'
    A=M             // A = the actual screen address stored in rowaddr
                    //     (this is the key step: indirect addressing)
    M=D             // Screen[rowaddr] = color  (paint 16 pixels at once!)

    // --- Advance rowaddr to the next word in this row ---
    @rowaddr        // A = address of 'rowaddr'
    M=M+1           // rowaddr = rowaddr + 1 (move to next 16-pixel word)

    // --- Decrement the column counter ---
    @cols           // A = address of 'cols'
    M=M-1           // cols = cols - 1 (one fewer word left to paint)

    // --- Loop back to paint the next word in this row ---
    @COLLOOP        // prepare to jump to COLLOOP
    0;JMP           // unconditional jump back to COLLOOP

// =====================
// NEXTROW — move to the next row of the box
// =====================
(NEXTROW)
    // --- Advance addr by 32 to reach the same column in the next row ---
    //     (Each screen row is 32 words apart in memory)
    @32             // A = 32 (number of words per screen row)
    D=A             // D = 32
    @addr           // A = address of 'addr'
    M=D+M           // addr = addr + 32 (now points to the next row)

    // --- Decrement the row counter ---
    @rows           // A = address of 'rows'
    M=M-1           // rows = rows - 1 (one fewer row left to paint)

    // --- Loop back to process the next row ---
    @ROWLOOP        // prepare to jump to ROWLOOP
    0;JMP           // unconditional jump back to ROWLOOP
