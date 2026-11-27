#set document(title: "Nand to Tetris Capstone Report - Make the Computer Draw a Box", author: "Tushar Sharma")

#let show_header = state("show_header", false)

#set page(
  paper: "a4",
  margin: (top: 2.1cm, bottom: 2.0cm, left: 2.2cm, right: 2.2cm),
  header: context {
    if show_header.get() and counter(page).get().first() > 1 {
      grid(
        columns: (1fr, 1fr),
        align(left)[#text(size: 8.8pt, weight: "bold", fill: rgb("#195693"))[Capstone Project: Make the Computer Draw a Box]],
        align(right)[#text(size: 8.8pt, fill: rgb("#4b5563"))[Tushar Sharma · Roll No: 2501730122 · Section B]]
      )
      v(-0.4em)
      line(length: 100%, stroke: 0.5pt + rgb("#c6d1dd"))
    }
  },
  footer: context {
    if show_header.get() {
      align(center)[#text(size: 9pt, fill: rgb("#4b5563"))[#counter(page).display()]]
    }
  }
)

#set text(font: "Libertinus Serif", size: 9.8pt, fill: rgb("#1e1e1e"), spacing: 108%)
#set par(justify: true, leading: 0.60em)

// Styling headings
#show heading.where(level: 1): it => block(spacing: 0.85em)[
  #text(size: 13pt, weight: "bold", fill: rgb("#195693"))[#it.body]
]
#show heading.where(level: 2): it => block(spacing: 0.65em)[
  #text(size: 10.8pt, weight: "bold", fill: rgb("#195693"))[#it.body]
]
#show heading.where(level: 3): it => block(spacing: 0.5em)[
  #text(size: 9.8pt, weight: "bold", fill: rgb("#195693"))[#it.body]
]

// Styling raw code blocks
#show raw.where(block: true): it => block(
  fill: rgb("#fff1f2"),
  stroke: 0.6pt + rgb("#e11d48"),
  inset: 6.5pt,
  radius: 3pt,
  width: 100%,
  text(font: "DejaVu Sans Mono", size: 7.8pt, fill: rgb("#881337"), it)
)

// Styling tables
#set table(
  stroke: (x, y) => if y == 0 { (bottom: 1.2pt + rgb("#195693"), top: 0.6pt + rgb("#c6d1dd")) } else { 0.5pt + rgb("#e2e8f0") },
  fill: (col, row) => if row == 0 { rgb("#f1f5f9") } else if calc.even(row) { rgb("#f8fafc") } else { none },
  inset: 5pt
)

// =============================================================================
// --- PAGE 1: TITLE PAGE ---
// =============================================================================
#align(center)[
  #v(1.0cm)
  #image("krmu_logo.png", width: 62%)
  #v(2.0cm)
  
  #text(size: 20pt, weight: "bold", fill: rgb("#195693"))[Nand to Tetris – I (ETCCNT301)] \
  #v(0.3em)
  #text(size: 14pt, fill: rgb("#4b5563"))[Capstone Project Report] \
  #v(1.0em)
  #text(size: 23pt, weight: "bold", fill: rgb("#0f172a"))[Make the Computer Draw a Box] \
  #v(0.5em)
  #text(size: 11pt, style: "italic", fill: rgb("#64748b"))[Low-Level Hardware Chip Design, Two-Pass Hack Assembler, and Interactive Screen Memory Display]
  
  #v(3.8cm)
  
  #grid(
    columns: (1fr, 1fr),
    align(left)[
      #text(size: 10.5pt, weight: "bold", fill: rgb("#195693"))[SUBMITTED BY:] \
      #v(0.3em)
      #text(size: 11pt, weight: "bold")[Tushar Sharma] \
      Roll No: 2501730122 \
      B.Tech CSE (AI & ML) \
      Section: B \
      K.R. Mangalam University
    ],
    align(left)[
      #text(size: 10.5pt, weight: "bold", fill: rgb("#195693"))[SUBMITTED TO:] \
      #v(0.3em)
      #text(size: 11pt, weight: "bold")[Neetu Chauhan] \
      Department of Computer Science \
      School of Engineering & Technology \
      K.R. Mangalam University \
      Sohna Road, Gurugram, Haryana
    ]
  )
]

#pagebreak()

// =============================================================================
// --- PAGE 2: TABLE OF CONTENTS ---
// =============================================================================
#v(0.3cm)
#outline(title: "Contents", indent: auto)

#pagebreak()
#show_header.update(true)
#counter(page).update(1)

// =============================================================================
// --- BODY SECTIONS ---
// =============================================================================
= 1 Executive Summary
This capstone project report documents the design, implementation, and empirical verification of the complete Hack general-purpose computer system, encompassing digital hardware design, systems software compilation, and interactive low-level display driver programming. Conducted as part of the *Nand to Tetris – I (ETCCNT301)* curriculum at the School of Engineering & Technology, K.R. Mangalam University, this project synthesizes the core disciplines of computer engineering into a unified, functioning computing platform built from fundamental logic gates.

The engineering scope spans three foundational tiers:
1. *Hardware Architecture (Part A):* Construction and formal hardware simulation of the Central Processing Unit (`CPU.hdl`), the unified memory address space (`Memory.hdl`), and the top-level system bus wiring (`Computer.hdl`).
2. *Systems Software (Part B):* Engineering a two-pass assembly translator (`assembler.py`) in Python that resolves symbols, allocates RAM memory, translates Hack assembly mnemonics into 16-bit binary instructions, and enforces roll-number-specific error handling.
3. *Application Software & I/O (Part C):* Authoring an interactive screen rendering engine (`Box.asm`) directly in Hack machine language that monitors hardware keyboard scan codes and drives raster graphics on the 512×256 monochrome display via memory-mapped I/O.

*System Evaluation Summary:* All hardware components have been validated using the official Nand2Tetris Hardware Simulator test scripts (`CPU.tst`, `Memory.tst`, `ComputerAdd.tst`, `ComputerMax.tst`, `ComputerRect.tst`). The custom Python assembler was verified against the official benchmark suite (`Add`, `Max`, `Rect`, `Pong`), achieving a 100% bitwise instruction match across 27,483 lines of machine code. Finally, the interactive graphics program was compiled with the author's assembler and verified in the CPU Emulator, satisfying all mathematical constraints derived from student roll number *2501730122*.

= 2 Project Overview and Objectives
The central objective of this capstone project is to demonstrate end-to-end fluency with Von Neumann computer systems by taking a high-level interactive user requirement—*showing a black box on the screen while a physical key is held down*—and realizing it across all abstraction layers without third-party operating systems or pre-compiled runtimes.

The specific project deliverables and academic goals comprise:
- *Computer Realization:* Integrating elementary multiplexers, registers (`ARegister`, `DRegister`), the Arithmetic Logic Unit (ALU), and the Program Counter (PC) into a unified processing unit operating on a two-phase clock.
- *Memory Map Unification:* Designing an address decoder that transparently multiplexes 16K words of general-purpose RAM, 8K words of video display memory, and a 1-word keyboard memory map.
- *Cross-Platform Assembler:* Implementing a robust two-pass lexical parser and code generator in Python capable of handling arbitrary label forward-references, variable bindings, and line-precise diagnostics.
- *Screen Memory Graphics:* Leveraging indirect memory addressing to paint multi-word horizontal raster lines at hardware refresh rates.

= 3 Personal Parameters & Mathematical Derivations
In accordance with the official project specification, every student is assigned unique geometrical and algorithmic parameters derived mathematically from their university registration number.

#table(
  columns: (1.5fr, 1.2fr, 2.5fr),
  [*Specification Parameter*], [*Evaluated Value*], [*Mathematical Formula & Derivation*],
  [Student Roll Number], [`2501730122`], [University Registration Identifier],
  [Personal Constant ($K$)], [$K = 22$], [Last two digits of roll number: $K = 22$],
  [Box Starting Row], [Row 22], [Top border row index: $"Row" = K = 22$],
  [Box Vertical Height], [20 rows], [Fixed height spanning Row 22 through Row 41],
  [Box Pixel Width], [48 pixels], [$16 times ((K space mod space 4) + 1) = 16 times ((22 space mod space 4) + 1) = 16 times 3 = 48 "px"$],
  [Box Word Span], [3 words / row], [$48 "pixels" / 16 "bits/word" = 3 "consecutive 16-bit words per row"$],
  [Screen Base Address], [Address 16384], [Base memory-mapped screen segment (`@SCREEN`)],
  [Initial Screen Offset], [704 words], [Row offset: $32 "words/row" times 22 "rows" = 704 "words"$],
  [Box Start Address in RAM], [Address 17088], [Absolute address: $16384 + 704 = 17088$ (`SCREEN + 704`)],
  [Assembler Extra Feature], [Feature 1], [$K space mod space 3 = 22 space mod space 3 = 1$ (Error diagnostics with line numbers)]
)

= 4 Phase 1 — Hardware Architecture & Computer Implementation (Part A)

#align(center)[
  #image("hack_architecture_diagram.png", width: 84%)
  #v(-0.4em)
  #text(size: 8.2pt, style: "italic", fill: rgb("#4b5563"))[*Figure 1:* Architectural block diagram of the Hack Computer (`Computer.hdl`) showing feedback loops between ROM32K, CPU, and Memory.]
]

== 4.1 Central Processing Unit (`CPU.hdl`)
The Hack CPU is a 16-bit processor capable of executing two types of instructions: A-instructions (address/constant loading) and C-instructions (computation, storage, and branching). The design cleanly separates control decoding, arithmetic processing, register storage, and program sequencing into an 8-stage execution pipeline:

1. *Instruction Decoding:* The most significant bit (`instruction[15]`) partitions instructions into A-instructions (`bit 15 = 0`) and C-instructions (`bit 15 = 1`). A pair of inverters (`Not` gates) derives the active-high control flags `isAinst` and `isCinst`.
2. *A-Register Multiplexing:* An initial `Mux16` gate selects the input to the Address Register (`ARegister`). Under an A-instruction, the raw 15-bit immediate constant is routed to A. Under a C-instruction where destination bit $d_1 = 1$ (`instruction[5]`), the ALU computation output (`aluOut`) is directed into A.
3. *ALU Input Selection ($a$-bit):* Bit 12 of the instruction word acts as the selector for a second `Mux16` gate. When $a = 0$, the ALU's second input is drawn from the internal `A` register. When $a = 1$, input is drawn from external memory (`inM = RAM[A]`), enabling seamless memory arithmetic.
4. *Data Register (`DRegister`):* The general-purpose 16-bit `D` register stores transient values and is updated during C-instructions whenever destination bit $d_2 = 1$ (`instruction[4]`).
5. *Arithmetic Logic Unit:* Computes sixteen mathematical and logical functions (`0`, `1`, `-1`, `D`, `A`, `!D`, `D+1`, `D+A`, `D-A`, `D&A`, `D|A`, etc.) using six control flags (`zx`, `nx`, `zy`, `ny`, `f`, `no`) mapped directly from `instruction[11..6]`. The ALU concurrently asserts `zr` (zero result) and `ng` (negative result).
6. *Memory Write Assertion:* The memory write enable line (`writeM`) is driven by the logical conjunction of `isCinst` and destination bit $d_3$ (`instruction[3]`), ensuring accidental writes do not occur during constant loads.
7. *Conditional Branch Evaluator:* Jump logic decodes bits $j_1, j_2, j_3$ (`instruction[2..0]`) in combination with the ALU status lines (`zr`, `ng`). If the branch condition is met during a C-instruction, `jump` asserts high.
8. *Program Counter (`PC`):* The 16-bit program counter sequencing chip evaluates control lines with strict priority: `reset` forces the counter to 0; `load` (driven by `jump`) latches address `A`; otherwise, `inc = 1` advances execution to the sequential ROM instruction.

== 4.2 Memory Subsystem and Address Mapping (`Memory.hdl`)
The memory chip coordinates the entire data address space of the Hack platform, transparently mapping three physically disparate hardware peripherals across a 15-bit address space ($2^{15} = 32,768$ addressable words).

#table(
  columns: (1.5fr, 1.2fr, 1.2fr, 2.5fr),
  [*Device Name*], [*Word Capacity*], [*Hex Range*], [*Address Decoding & Functional Purpose*],
  [Data RAM (`RAM16K`)], [16,384 words], [`0x0000 – 0x3FFF`], [Selected when `address[14] = 0`. General data, variables, stack, and heap storage.],
  [Monochrome Screen], [8,192 words], [`0x4000 – 0x5FFF`], [Selected when `address[14..13] = 10`. Memory-mapped video buffer controlling $512 times 256$ pixels.],
  [Keyboard Register], [1 word], [`0x6000`], [Selected when `address[14..13] = 11`. Read-only hardware register holding scan codes (address 24576).]
)

*Address Decoding Architecture:* A `DMux4Way` routes the write enable signal (`load`) based on the most significant address bits `address[13..14]`. When `address[14] = 0`, either output `a` or `b` fires; an `Or` gate merges these into `loadRAM`, routing writes to `RAM16K(address[0..13])`. When `address[14..13] = 10`, output `c` asserts `loadScreen`, updating `Screen(address[0..12])`. Output `d` corresponds to the keyboard; because physical keyboards are read-only, this load line is intentionally discarded to prevent bus contention.

Output retrieval is managed symmetrically by a `Mux4Way16`, which inspects `address[13..14]` and multiplexes the data output from `ramOut`, `screenOut`, or `kbdOut` back to the CPU bus `out[16]`.

== 4.3 Top-Level Computer Wiring (`Computer.hdl`)
The top-level `Computer.hdl` chip instantiates the complete Von Neumann machine by interconnecting `ROM32K`, `CPU`, and `Memory` in an unbroken closed-loop bus topology:

#block(
  fill: rgb("#fffbeb"),
  stroke: (left: 3pt + rgb("#f59e0b"), rest: 0.5pt + rgb("#fde68a")),
  inset: 8.5pt,
  radius: (right: 4pt),
  [
    #text(weight: "bold", fill: rgb("#92400e"))[Hardware Interconnect Verification Principle] \
    #v(0.2em)
    #text(size: 9.3pt, fill: rgb("#78350f"))[
      The top-level computer requires zero internal logic gates—it functions exclusively via pure bus routing:
      `ROM32K(address=pc, out=instruction)` feeds the program word into `CPU(instruction=instruction, inM=memOut)`. The CPU emits memory write parameters `CPU(outM=outM, writeM=writeM, addressM=addressM)` into `Memory(in=outM, load=writeM, address=addressM)`, whose output `Memory(out=memOut)` feeds directly back into the CPU.
    ]
  ]
)

= 5 Phase 2 — Two-Pass Hack Assembler Implementation (Part B)
== 5.1 Two-Pass Translation Architecture (`assembler.py`)
Machine hardware is fundamentally incapable of resolving symbolic variables or jumping to human-readable labels such as `(LOOP)` directly. The custom Hack Assembler written in Python (`assembler.py`) bridges this semantic gap through an architecturally decoupled two-pass compiler pipeline:

1. *Pre-Processing & Pass 1 (Symbolic Address Recording):*
   - Reads the raw `.asm` source, eliminating comments (`//`), trailing whitespace, and empty lines.
   - Maintains an internal ROM instruction counter `rom_address` initialized to 0.
   - When encountering a pseudo-instruction label declaration `(LABEL)`, the assembler enters the symbol into the hash table: `symbol_table["LABEL"] = rom_address`.
   - Crucially, *pseudo-instructions do not generate machine code*; therefore, `rom_address` is not incremented, ensuring that the label points precisely to the subsequent executable instruction.
2. *Pass 2 (Binary Code Synthesis & Memory Allocation):*
   - Iterates through the sanitized source code, translating each mnemonic into a 16-bit binary string.
   - For A-instructions (`@symbol`): If the symbol is numeric (`@22`), it is converted directly to 15-bit binary prefixed with `0`. If symbolic, it is queried against the symbol table. If absent, the assembler dynamically binds it to the next available RAM register (allocating consecutively from RAM address `16, 17, 18, ...`).
   - For C-instructions (`dest=comp;jump`): Deconstructs the mnemonic into component tokens, verifies syntax against predefined instruction tables, and synthesizes the binary format: `111` + 7-bit `comp` + 3-bit `dest` + 3-bit `jump`.

== 5.2 Symbol Resolution and Lookup Tables
The assembler embeds the official Hack predefined symbol table, mapping hardware architectural registers (`R0`–`R15` to $0$–$15$), memory segment pointers (`SP=0`, `LCL=1`, `ARG=2`, `THIS=3`, `THAT=4`), and memory-mapped I/O base addresses (`SCREEN=16384`, `KBD=24576`).

#table(
  columns: (1fr, 1.2fr, 2.5fr),
  [*Instruction Field*], [*Bit Layout*], [*Operational Mapping & Translation Strategy*],
  [A-Instruction], [`0vvv vvvv vvvv vvvv`], [Bit 15 is 0; bits 0..14 store the 15-bit immediate address or numerical literal.],
  [C-Instruction Opcode], [`111`], [Bits 13..15 are fixed to `111` to identify a computation instruction.],
  [Comp Field ($a + c$ bits)], [`a c1 c2 c3 c4 c5 c6`], [Bit 12 ($a$-bit) selects register A (0) or Memory M (1); bits 6..11 configure ALU control lines.],
  [Dest Field ($d$ bits)], [`d1 d2 d3`], [Bit 5 controls register A; bit 4 controls register D; bit 3 controls Memory write enable.],
  [Jump Field ($j$ bits)], [`j1 j2 j3`], [Bit 2 triggers on negative ($<0$); bit 1 on zero ($=0$); bit 0 on positive ($>0$).]
)

== 5.3 Roll-Specific Extra Feature: Line-by-Line Error Reporting ($K mod 3 = 1$)
Because the author's roll number parameter evaluates to $K space mod space 3 = 22 space mod space 3 = 1$, the assembler is explicitly engineered with *graceful, non-crashing syntax validation and line-number error reporting*.

Unlike standard scripting implementations that throw unhandled Python exceptions (such as `KeyError` or `IndexError`) and crash abruptly upon encountering malformed assembly code, this assembler isolates errors and reports clean diagnostics:

```text
Assembling: BadInstruction.asm
Total source lines: 7
Instructions after stripping comments/labels: 5
Line 5: invalid instruction 'INVALID_INSTRUCTION' — unknown comp mnemonic 'INVALID_INSTRUCTION'

Assembly completed with 1 error(s).
Output file NOT written due to errors.
```

*Architectural Resilience Guard:* When syntax or mnemonic violations occur, the assembler records the original physical line number, increments an error accumulator, logs a precise diagnostic message to `stderr`, and aborts file serialization. This guarantees that corrupted or partial machine code is never emitted to disk.

#table(
  columns: (1.2fr, 1.8fr, 2fr),
  [*Benchmark Program*], [*Assembly Scale*], [*Verification Result via compare.py*],
  [`Add.asm`], [6 executable instructions], [Bitwise exact match against `OfficialAdd.hack` (6 lines)],
  [`Max.asm`], [16 executable instructions], [Bitwise exact match against `OfficialMax.hack` (16 lines)],
  [`Rect.asm`], [25 executable instructions], [Bitwise exact match against `OfficialRect.hack` (25 lines)],
  [`Pong.asm`], [27,483 instructions], [Bitwise exact match against `OfficialPong.hack` (27,483 lines)]
)

= 6 Phase 3 — Interactive Screen Driver & Display Logic (Part C)

#align(center)[
  #image("screen_memory_diagram.png", width: 84%)
  #v(-0.4em)
  #text(size: 8.2pt, style: "italic", fill: rgb("#4b5563"))[*Figure 2:* Geometry and memory addressing mapping of the 512×256 Hack screen highlighting the $K=22$ box raster position.]
]

== 6.1 Screen Memory Mapping & Raster Mathematics
The Hack display system utilizes memory-mapped raster graphics. The display resolution is 512 horizontal pixels by 256 vertical lines. Pixels are organized in horizontal 16-bit words:
$ "Words per Row" = frac(512 "pixels", 16 "bits/word") = 32 "words/row" $
The screen buffer resides in RAM beginning at address $16384$ (`SCREEN`). The base memory address for any screen coordinate $("row", "col_word")$ is expressed analytically as:
$ "Address"("row", "col_word") = 16384 + (32 times "row") + "col_word" $

For roll number $2501730122$ ($K = 22$), the geometrical parameters are strictly bounded:
- *Top Boundary:* Row $r = 22$.
- *Vertical Dimension:* Exactly $20$ rows, extending from Row 22 through Row 41.
- *Horizontal Span:* $16 times ((22 space mod space 4) + 1) = 16 times (2 + 1) = 48 "pixels"$, corresponding to exactly $3$ consecutive 16-bit words (`col_word = 0, 1, 2`).
- *Starting Physical Memory Address:*
  $ "Start Address" = 16384 + (32 times 22) + 0 = 16384 + 704 = bold(17088) $

== 6.2 Keyboard Polling and Event Loop State Machine (`Box.asm`)
The software driver implements an uninterrupted polling loop that samples the physical keyboard register at address `24576` (`KBD`).

```hack
// Box.asm — Core Polling and Raster State Machine
(LOOP)
    @KBD
    D=M             // Read scan code from hardware register
    @SETBLACK
    D;JNE           // Key pressed (scan code != 0) -> Paint black
    @color
    M=0             // Key released (scan code == 0) -> Paint white
    @RENDER
    0;JMP
(SETBLACK)
    @color
    M=-1            // -1 in two's complement = 1111111111111111 (16 black pixels)
```

The rendering kernel executes nested iteration: an outer loop counts down 20 rows, and an inner loop writes the 16-bit color pattern across 3 words using indirect addressing (`A=M; M=D`), advancing by 32 words per raster scanline.

= 7 Phase 4 — Verification, Simulation, and Test Evidence
== 7.1 Hardware Test Suite Execution
Every chip implementation was verified against formal test scripts in the Nand2Tetris Hardware Simulator:
- `CPU.tst`: Evaluated instruction decoding, ALU arithmetic, memory write permissions, and conditional jump branching. Simulation completed with zero comparison failures.
- `Memory.tst`: Evaluated boundary addressing across RAM16K, Screen boundary limits, and keyboard read cycles. Output matched `Memory.cmp` completely.
- `ComputerAdd.tst`, `ComputerMax.tst`, `ComputerRect.tst`: Simulated full-system program execution over hundreds of clock cycles, proving that instruction fetching, program counter incrementing, and memory writes synchronize flawlessly.

== 7.2 Assembler Benchmark Comparison (`compare.py`)
To satisfy the grading mandate of Part B, the automated validation tool `compare.py` was executed across all standard test assemblies.

#block(
  fill: rgb("#f0fdf4"),
  stroke: (left: 3pt + rgb("#16a34a"), rest: 0.5pt + rgb("#bbf7d0")),
  inset: 8pt,
  radius: (right: 4pt),
  [
    #text(weight: "bold", fill: rgb("#15803d"))[Automated Benchmark Verification Output] \
    #v(0.2em)
    #text(font: "DejaVu Sans Mono", size: 8pt, fill: rgb("#166534"))[
      \$ python3 compare.py \
      Add  -> MATCH ( 6 lines ) \
      Max  -> MATCH ( 16 lines ) \
      Rect -> MATCH ( 25 lines ) \
      Pong -> MATCH ( 27483 lines )
    ]
  ]
)

== 7.3 Interactive Box Execution in CPU Emulator
The assembled machine code `Box.hack` (55 binary instructions) was loaded into the official Nand2Tetris CPU Emulator:
1. *Idle State:* With no keyboard key pressed, `RAM[24576]` reads `0`. The render loop continually writes `0` (`0x0000`) across words $0$ to $2$ of rows $22$ to $41$, leaving the screen canvas completely clear.
2. *Active State:* When any key is depressed, `RAM[24576]` receives the key's hardware scan code. The driver immediately asserts `color = -1` (`0xFFFF`), illuminating an unbroken 48×20 rectangular black block at Row 22.
3. *Release State:* Releasing the key instantaneously clears `RAM[24576]`, and the subsequent frame erases the box without visual artifacting or screen flicker.

= 8 Phase 5 — Defects Diagnosed and Debugging Journey
== 8.1 Key Mistake Diagnosed and Fixed
During the initial development of the interactive screen driver in `Box.asm`, an addressing bug caused the program to draw vertical lines rather than a solid horizontal block. The root cause was traced to an *unintended aliasing of the row-base address pointer*. 

In the original code, the inner column loop directly incremented the primary row address variable `addr` (`addr = addr + 1`). Consequently, when the outer loop attempted to advance to the next line using `addr = addr + 32`, the base pointer had already shifted by 3 words, causing each subsequent row to begin 3 words further to the right. This resulted in a jagged diagonal smear across the screen. 

The issue was diagnosed using CPU Emulator breakpoint inspection and resolved by introducing a dedicated transient pointer `rowaddr`. In the corrected implementation, `rowaddr` copies `addr` at the start of each row and is incremented across the 3 words, while `addr` remains pristine and is advanced strictly by $+32$ at each scanline transition.

== 8.2 Assembler Jump Field Bit-Shift Resolution
During early testing of `assembler.py` against `Max.asm`, conditional jumps failed to trigger in the emulator. Inspection revealed that the jump binary lookup table lacked right-alignment padding, causing jump bits to overwrite destination fields. The token parser was refactored with explicit 3-bit zero-padded binary formatting (`f"{jump_val:03b}"`), completely eliminating instruction corruption.

= 9 Completion Assessment and Status Matrix
#table(
  columns: (1.5fr, 1.2fr, 2.3fr),
  [*Project Component*], [*Audit Status*], [*Evaluation Criteria & Functional Evidence*],
  [Hardware CPU (`CPU.hdl`)], [Verified Complete], [Passes `CPU.tst` with zero discrepancies; proper A/C decoding and ALU flag jumps.],
  [Hardware Memory (`Memory.hdl`)], [Verified Complete], [Passes `Memory.tst`; seamless routing of RAM16K, Screen, and Keyboard registers.],
  [Computer Chip (`Computer.hdl`)], [Verified Complete], [Passes `ComputerAdd`, `ComputerMax`, and `ComputerRect` full-system execution.],
  [Two-Pass Assembler (`assembler.py`)], [Verified Complete], [100% bitwise parity on `Add`, `Max`, `Rect`, and `Pong` (27,483 instructions).],
  [Assembler Extra Feature ($K mod 3 = 1$)], [Verified Complete], [Traps malformed assembly with line numbers; tested via `BadInstruction.asm`.],
  [Interactive Box Driver (`Box.asm`)], [Verified Complete], [Accurately renders 48×20 box at Row 22 (SCREEN + 704 = 17088) upon keypress.]
)

= 10 Conclusion
The Nand to Tetris Capstone Project represents a comprehensive practical mastery of computer systems from first principles. By designing the digital logic circuitry in HDL, developing a systems-level two-pass assembler in Python, and authoring an interactive memory-mapped graphical application in Hack assembly, this project demonstrates how physical transistors coalesce into an operational, programmable computer.

The implementation rigorously satisfies all mathematical criteria dictated by student registration number *2501730122*, delivering a reliable, verifiable, and academically robust solution.

= 11 Glossary
- *ALU (Arithmetic Logic Unit):* The central combinational chip inside the CPU that executes 16-bit arithmetic and logic functions.
- *Memory-Mapped I/O:* An architectural technique where hardware peripherals (screen and keyboard) are addressed through standard memory read/write instructions rather than dedicated bus channels.
- *Two-Pass Assembler:* A language translator that scans source code twice: first to construct a symbolic label table, and second to generate binary instructions.
- *Scan Code:* A unique numeric identifier loaded into the keyboard memory register representing the physical key being depressed.
- *Raster Graphics:* A display technique where graphical objects are constructed line-by-line from horizontal rows of individual pixels.

= 12 Appendix — Viva Voce Quick-Reference Guide
During the 5-minute technical viva, examiners evaluate student comprehension by requesting on-the-spot code modifications. The following reference outlines the exact line modifications required:

#table(
  columns: (1.8fr, 1.4fr, 2fr),
  [*Examiner Request*], [*Target in Box.asm*], [*Required Code Modification*],
  [Move box down by 10 rows (to Row 32)], [`(RENDER)` segment], [Change `@704` to `@1024` (calculation: $32 "words/row" times 32 "rows" = 1024$).],
  [Make box wider (4 words / 64 pixels)], [`(ROWLOOP)` segment], [Change column counter load from `@3` to `@4`.],
  [Make box taller (30 rows tall)], [`(RENDER)` segment], [Change row counter initialization from `@20` to `@30`.],
  [Move box right by 32 pixels (2 words)], [`(RENDER)` segment], [Change base screen offset from `@704` to `@706` ($704 + 2$).],
  [Invert key behavior (box vanishes on key)], [`(LOOP)` segment], [Swap color assignments: set `M=-1` on key release and `M=0` on key press.]
)
