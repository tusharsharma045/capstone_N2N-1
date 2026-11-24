#!/usr/bin/env python3
"""
Hack Assembler — Nand to Tetris Capstone Project
Roll Number: 2501730122 | K = 22 | K mod 3 = 1
Extra Feature: Error reporting with line numbers

This assembler converts Hack assembly (.asm) files into
Hack machine code (.hack) files (16-bit binary instructions).

Usage: python assembler.py <filename.asm>

Two-pass assembler:
  Pass 1 – Strip comments and blank lines, record label addresses
           in the symbol table.
  Pass 2 – Translate every remaining instruction into a 16-bit
           binary string.  Errors are reported with line numbers
           instead of crashing.
"""

import sys   # for command-line arguments and exit codes



#                       LOOKUP TABLES

# ─── COMP TABLE 
# Maps each comp mnemonic to a 7-bit string: a-bit + 6 ALU bits.
# When a = 0 the ALU reads the A register;
# when a = 1 it reads M (RAM[A]) instead.
COMP_TABLE = {
    # a = 0  (operations that use A)
    "0":   "0101010",
    "1":   "0111111",
    "-1":  "0111010",
    "D":   "0001100",
    "A":   "0110000",
    "!D":  "0001101",
    "!A":  "0110001",
    "-D":  "0001111",
    "-A":  "0110011",
    "D+1": "0011111",
    "A+1": "0110111",
    "D-1": "0001110",
    "A-1": "0110010",
    "D+A": "0000010",
    "D-A": "0010011",
    "A-D": "0000111",
    "D&A": "0000000",
    "D|A": "0010101",
    # a = 1  (operations that use M)
    "M":   "1110000",
    "!M":  "1110001",
    "-M":  "1110011",
    "M+1": "1110111",
    "M-1": "1110010",
    "D+M": "1000010",
    "D-M": "1010011",
    "M-D": "1000111",
    "D&M": "1000000",
    "D|M": "1010101",
}

# ─── DEST TABLE 
# Which register(s) receive the ALU output.
# 3 bits: d1 d2 d3  →  A  D  M
DEST_TABLE = {
    "null": "000",   # result is not stored
    "M":    "001",   # RAM[A]
    "D":    "010",   # D register
    "MD":   "011",   # both M and D
    "A":    "100",   # A register
    "AM":   "101",   # A and M
    "AD":   "110",   # A and D
    "AMD":  "111",   # A, M, and D
}

# ─── JUMP TABLE 
# When to jump, based on ALU output compared to zero.
# 3 bits: j1 j2 j3  →  <0  =0  >0
JUMP_TABLE = {
    "null": "000",   # no jump
    "JGT":  "001",   # jump if out > 0
    "JEQ":  "010",   # jump if out = 0
    "JGE":  "011",   # jump if out ≥ 0
    "JLT":  "100",   # jump if out < 0
    "JNE":  "101",   # jump if out ≠ 0
    "JLE":  "110",   # jump if out ≤ 0
    "JMP":  "111",   # unconditional jump
}

# ─── PRE-DEFINED SYMBOLS ─────────────────────────────────────
# These symbols are built into the Hack platform and are
# always available without the programmer declaring them.
PREDEFINED_SYMBOLS = {
    "SP":     0,       # Stack pointer
    "LCL":    1,       # Local segment base
    "ARG":    2,       # Argument segment base
    "THIS":   3,       # THIS segment base
    "THAT":   4,       # THAT segment base
    "SCREEN": 16384,   # Start of screen memory map
    "KBD":    24576,   # Keyboard memory-mapped register
}

# Add virtual registers R0 – R15, which map to RAM[0] – RAM[15].
for i in range(16):
    PREDEFINED_SYMBOLS[f"R{i}"] = i



#                        FUNCTIONS
 


def clean_line(raw_line):
    """
    Remove inline comments and surrounding whitespace from a raw
    assembly line.

    Args:
        raw_line (str): One line read from the .asm file.

    Returns:
        str: The cleaned line (may be empty if the line was blank
             or contained only a comment).

    Example:
        clean_line("  D=A  // set D to A ") → "D=A"
    """
    # Strip everything from '//' onward (inline comments).
    comment_index = raw_line.find("//")
    if comment_index != -1:
        raw_line = raw_line[:comment_index]

    # Remove leading/trailing whitespace and return.
    return raw_line.strip()


def first_pass(lines):
    """
    First pass of the assembler.

    Walk through every line of the source file and:
      1. Remove comments and blank lines.
      2. Detect label declarations like (LOOP) and record them
         in the symbol table with the ROM address of the NEXT
         instruction.
      3. Collect the remaining (non-label) lines as "clean lines"
         for the second pass.

    Args:
        lines (list[str]): Raw lines from the .asm file.

    Returns:
        clean_lines  (list[tuple[int, str]]):
            Each entry is (original_line_number, cleaned_instruction).
        symbol_table (dict[str, int]):
            Mapping from symbol names to their addresses.
    """
    # Start the symbol table with all predefined symbols.
    symbol_table = dict(PREDEFINED_SYMBOLS)

    clean_lines = []       # will hold (line_number, instruction)
    rom_address = 0        # tracks the address of the next instruction in ROM

    for line_number, raw_line in enumerate(lines, start=1):
        # --- Step 1: strip comments and whitespace ---
        line = clean_line(raw_line)

        # Skip blank lines.
        if line == "":
            continue

        # --- Step 2: check for label declarations ---
        # Labels look like (LABEL_NAME).  They do NOT occupy a
        # ROM address; they simply mark the address of whatever
        # instruction comes next.
        if line.startswith("(") and line.endswith(")"):
            label = line[1:-1]          # extract the name between parens
            symbol_table[label] = rom_address
            continue                    # labels produce no machine code

        # --- Step 3: keep the instruction for pass 2 ---
        clean_lines.append((line_number, line))
        rom_address += 1               # only real instructions advance ROM

    return clean_lines, symbol_table


def parse_a_instruction(token, symbol_table, next_var_address):
    """
    Translate an A-instruction (@value) into a 16-bit binary string.

    If the value after '@' is a decimal number, convert it directly.
    If it is a symbol, look it up in the symbol table.  If the
    symbol hasn't been seen before, assign it the next available
    variable address (starting at RAM[16]).

    Args:
        token            (str):           The part after '@', e.g. "42" or "i".
        symbol_table     (dict[str,int]): Current symbol table (may be updated).
        next_var_address (int):           Next free RAM address for variables.

    Returns:
        binary           (str): 16-bit binary string (e.g. "0000000000010000").
        next_var_address (int): Possibly incremented if a new variable was added.

    Raises:
        ValueError: If the numeric value is out of the 15-bit range (0–32767).
    """
    if token.isdigit():
        # ── Numeric constant ──
        value = int(token)
        if value < 0 or value > 32767:
            raise ValueError(f"numeric value {value} out of range 0-32767")
    else:
        # ── Symbol ──
        if token not in symbol_table:
            # First time seeing this variable: assign it a RAM address.
            symbol_table[token] = next_var_address
            next_var_address += 1

        value = symbol_table[token]

    # Format as 16-bit binary: leading '0' (A-instruction marker)
    # followed by the 15-bit address.
    binary = "0" + format(value, "015b")
    return binary, next_var_address


def parse_c_instruction(line):
    """
    Translate a C-instruction into a 16-bit binary string.

    A C-instruction has the general form:   dest = comp ; jump
    Both 'dest=' and ';jump' are optional.

    Binary layout (16 bits):
        1  1  1  a  c1 c2 c3 c4 c5 c6  d1 d2 d3  j1 j2 j3
        ──────  ───────────────────────  ────────  ────────
        opcode        comp field          dest      jump

    Args:
        line (str): The cleaned C-instruction text.

    Returns:
        str: 16-bit binary string.

    Raises:
        ValueError: If any comp, dest, or jump mnemonic is invalid.
    """
    # ── Split dest, comp, and jump ──

    # Default values when the part is absent.
    dest_mnemonic = "null"
    jump_mnemonic = "null"

    # Check for '=' (dest part) and ';' (jump part).
    if "=" in line:
        dest_mnemonic, line = line.split("=", 1)  # split once on '='
    if ";" in line:
        comp_mnemonic, jump_mnemonic = line.split(";", 1)
    else:
        comp_mnemonic = line

    # Strip whitespace from each part for safety.
    dest_mnemonic = dest_mnemonic.strip()
    comp_mnemonic = comp_mnemonic.strip()
    jump_mnemonic = jump_mnemonic.strip()

    # ── Look up each field in the tables ──

    if comp_mnemonic not in COMP_TABLE:
        raise ValueError(f"unknown comp mnemonic '{comp_mnemonic}'")

    if dest_mnemonic not in DEST_TABLE:
        raise ValueError(f"unknown dest mnemonic '{dest_mnemonic}'")

    if jump_mnemonic not in JUMP_TABLE:
        raise ValueError(f"unknown jump mnemonic '{jump_mnemonic}'")

    comp_bits = COMP_TABLE[comp_mnemonic]   # 7 bits (includes a-bit)
    dest_bits = DEST_TABLE[dest_mnemonic]   # 3 bits
    jump_bits = JUMP_TABLE[jump_mnemonic]   # 3 bits

    # ── Assemble the 16-bit instruction ──
    # Bits 15-13 are always 111 for a C-instruction.
    binary = "111" + comp_bits + dest_bits + jump_bits
    return binary


def second_pass(clean_lines, symbol_table):
    """
    Second pass: translate every instruction to 16-bit binary.

    Walks through the cleaned instruction list produced by the
    first pass and converts each line:
      • A-instructions (@value) → call parse_a_instruction
      • C-instructions         → call parse_c_instruction

    Error handling (extra feature for K mod 3 = 1):
      If any instruction cannot be parsed, a clear error message
      is printed with the original source line number.  The
      assembler does NOT crash; it continues processing and
      collects all errors.  If there were errors, the output
      file will not be written.

    Args:
        clean_lines  (list[tuple[int, str]]): (line_number, instruction).
        symbol_table (dict[str, int]):        Symbol table from pass 1.

    Returns:
        machine_code (list[str]): List of 16-bit binary strings.
        error_count  (int):       Total number of errors encountered.
    """
    machine_code = []             # will hold one binary string per instruction
    next_var_address = 16         # variables start at RAM[16]
    error_count = 0               # tracks how many bad lines we found

    for line_number, instruction in clean_lines:
        try:
            if instruction.startswith("@"):
                # ── A-instruction ──
                token = instruction[1:]          # everything after '@'

                if token == "":
                    raise ValueError("missing value after '@'")

                binary, next_var_address = parse_a_instruction(
                    token, symbol_table, next_var_address
                )
            else:
                # ── C-instruction ──
                binary = parse_c_instruction(instruction)

            machine_code.append(binary)

        except ValueError as error:
            # ── Error reporting (K mod 3 = 1 feature) ──
            # Print a friendly message and keep going.
            print(f"Line {line_number}: invalid instruction "
                  f"'{instruction}' — {error}")
            error_count += 1

    return machine_code, error_count


def assemble(input_path):
    """
    Top-level assembly routine.

    Reads the .asm file, runs both passes, and writes the
    .hack output file.

    Args:
        input_path (str): Path to the input .asm file.

    Returns:
        bool: True if assembly succeeded with no errors,
              False otherwise.
    """
    # ── Read the source file ──
    try:
        with open(input_path, "r") as asm_file:
            lines = asm_file.readlines()
    except FileNotFoundError:
        print(f"Error: file '{input_path}' not found.")
        return False

    print(f"Assembling: {input_path}")
    print(f"Total source lines: {len(lines)}")

    # ── Pass 1 ──
    clean_lines, symbol_table = first_pass(lines)
    print(f"Instructions after stripping comments/labels: {len(clean_lines)}")

    # ── Pass 2 ──
    machine_code, error_count = second_pass(clean_lines, symbol_table)

    # ── Error summary ──
    if error_count > 0:
        print(f"\nAssembly completed with {error_count} error(s).")
        print("Output file NOT written due to errors.")
        return False

    # ── Write the output .hack file ──
    # Replace the .asm extension with .hack.
    if input_path.endswith(".asm"):
        output_path = input_path[:-4] + ".hack"
    else:
        output_path = input_path + ".hack"

    with open(output_path, "w") as hack_file:
        for binary_line in machine_code:
            hack_file.write(binary_line + "\n")

    print(f"\nAssembly completed with 0 error(s).")
    print(f"Output written to: {output_path}")
    print(f"Total instructions: {len(machine_code)}")
    return True


def main():
    """
    Main entry point.

    Reads the filename from the command-line arguments and
    runs the assembler.

    Usage:
        python assembler.py <filename.asm>
    """
    # Check that the user provided a filename.
    if len(sys.argv) != 2:
        print("Usage: python assembler.py <filename.asm>")
        sys.exit(1)

    input_path = sys.argv[1]

    # Run the assembler and set exit code accordingly.
    success = assemble(input_path)
    sys.exit(0 if success else 1)


# ── Only run main() when this file is executed directly ──
if __name__ == "__main__":
    main()
