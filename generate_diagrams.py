import matplotlib.pyplot as plt
import matplotlib.patches as patches

# --- Figure 1: Computer Architecture Diagram ---
fig, ax = plt.subplots(figsize=(8.5, 4.2), dpi=300)
ax.set_xlim(0, 100)
ax.set_ylim(0, 50)
ax.axis('off')

# Background container
bg = patches.FancyBboxPatch((2, 2), 96, 46, boxstyle="round,pad=1", edgecolor="#cbd5e1", facecolor="#f8fafc", linewidth=1.5)
ax.add_patch(bg)
ax.text(50, 45, "Hack Computer Architecture (Computer.hdl)", ha="center", va="center", fontsize=11, fontweight="bold", color="#1e293b")

# ROM32K
rom = patches.FancyBboxPatch((8, 24), 22, 16, boxstyle="round,pad=0.5", edgecolor="#2563eb", facecolor="#eff6ff", linewidth=1.5)
ax.add_patch(rom)
ax.text(19, 34, "ROM32K", ha="center", va="center", fontsize=10, fontweight="bold", color="#1d4ed8")
ax.text(19, 29, "Instruction\nMemory", ha="center", va="center", fontsize=8.5, color="#3b82f6")

# CPU
cpu = patches.FancyBboxPatch((38, 10), 24, 30, boxstyle="round,pad=0.5", edgecolor="#059669", facecolor="#ecfdf5", linewidth=1.8)
ax.add_patch(cpu)
ax.text(50, 36, "Hack CPU", ha="center", va="center", fontsize=11, fontweight="bold", color="#047857")
ax.text(50, 29, "ALU + Control\nA & D Registers\nProgram Counter (PC)", ha="center", va="center", fontsize=8, color="#065f46")
ax.text(50, 14, "Instruction Decoder", ha="center", va="center", fontsize=7.5, style="italic", color="#047857")

# Memory
mem = patches.FancyBboxPatch((70, 8), 22, 32, boxstyle="round,pad=0.5", edgecolor="#7c3aed", facecolor="#f5f3ff", linewidth=1.5)
ax.add_patch(mem)
ax.text(81, 36, "Memory.hdl", ha="center", va="center", fontsize=10, fontweight="bold", color="#6d28d9")
ax.text(81, 28, "RAM16K\n(0 – 16383)", ha="center", va="center", fontsize=7.5, color="#5b21b6")
ax.text(81, 20, "Screen (8K)\n(16384 – 24575)", ha="center", va="center", fontsize=7.5, color="#5b21b6")
ax.text(81, 12, "Keyboard (1W)\n(24576)", ha="center", va="center", fontsize=7.5, color="#5b21b6")

# Arrows
# ROM to CPU (instruction)
ax.annotate("", xy=(38, 33), xytext=(30, 33), arrowprops=dict(arrowstyle="->", color="#2563eb", lw=1.5))
ax.text(34, 35, "instruction", ha="center", va="bottom", fontsize=7.5, color="#1e40af", fontweight="bold")

# CPU to ROM (pc)
ax.annotate("", xy=(30, 27), xytext=(38, 27), arrowprops=dict(arrowstyle="->", color="#dc2626", lw=1.5))
ax.text(34, 25, "pc [15]", ha="center", va="top", fontsize=7.5, color="#b91c1c", fontweight="bold")

# CPU to Memory (outM, addressM, writeM)
ax.annotate("", xy=(70, 30), xytext=(62, 30), arrowprops=dict(arrowstyle="->", color="#059669", lw=1.5))
ax.text(66, 31.5, "outM [16]", ha="center", va="bottom", fontsize=7, color="#047857")

ax.annotate("", xy=(70, 25), xytext=(62, 25), arrowprops=dict(arrowstyle="->", color="#059669", lw=1.5))
ax.text(66, 26.5, "addressM [15]", ha="center", va="bottom", fontsize=7, color="#047857")

ax.annotate("", xy=(70, 20), xytext=(62, 20), arrowprops=dict(arrowstyle="->", color="#059669", lw=1.5))
ax.text(66, 21.5, "writeM [1]", ha="center", va="bottom", fontsize=7, color="#047857")

# Memory to CPU (inM)
ax.annotate("", xy=(62, 15), xytext=(70, 15), arrowprops=dict(arrowstyle="->", color="#7c3aed", lw=1.5))
ax.text(66, 13.5, "inM [16]", ha="center", va="top", fontsize=7, color="#6d28d9")

# Reset line
ax.annotate("", xy=(50, 10), xytext=(50, 4), arrowprops=dict(arrowstyle="->", color="#64748b", lw=1.5))
ax.text(50, 3, "reset", ha="center", va="top", fontsize=8, color="#475569", fontweight="bold")

plt.tight_layout()
plt.savefig("/home/tushar/personal/capstone/hack_architecture_diagram.png", bbox_inches='tight', dpi=300)
plt.close()


# --- Figure 2: Screen Memory Map Diagram ---
fig, ax = plt.subplots(figsize=(8.5, 4.2), dpi=300)
ax.set_xlim(0, 100)
ax.set_ylim(0, 50)
ax.axis('off')

# Display Screen Frame
screen = patches.FancyBboxPatch((15, 6), 70, 38, boxstyle="round,pad=0.5", edgecolor="#334155", facecolor="#ffffff", linewidth=1.5)
ax.add_patch(screen)
ax.text(50, 46.5, "Hack Screen Memory Map (256 Rows × 512 Pixels = 8,192 Words)", ha="center", va="center", fontsize=9.5, fontweight="bold", color="#1e293b")

# Outer boundary labels
ax.text(13, 44, "Row 0 (Addr: 16384)", ha="right", va="center", fontsize=7.5, color="#64748b")
ax.text(13, 7, "Row 255 (Addr: 24544)", ha="right", va="center", fontsize=7.5, color="#64748b")
ax.text(16, 42, "(0, 0)", ha="left", va="top", fontsize=7, color="#94a3b8")
ax.text(84, 42, "(511, 0)", ha="right", va="top", fontsize=7, color="#94a3b8")

# Box at Row 22 (scaled vertically)
# Y: 44 is row 0, 7 is row 255. Row 22 is near the top: 44 - (22/255)*37 ≈ 40.8
# Height 20 rows: (20/255)*37 ≈ 2.9
# Width: 48 pixels out of 512: (48/512)*70 ≈ 6.56
box_x = 16
box_y = 37.5
box_w = 7.5
box_h = 3.8

box_rect = patches.Rectangle((box_x, box_y), box_w, box_h, linewidth=1.2, edgecolor="#dc2626", facecolor="#0f172a")
ax.add_patch(box_rect)

# Annotations for Box
ax.annotate("Box Position for K = 22\n• Start Row: Row 22 (SCREEN + 704 = 17088)\n• Dimensions: 48 px wide (3 words) × 20 rows high\n• Behavior: Filled black (all 1s) when key pressed",
            xy=(box_x + box_w, box_y + box_h/2), xytext=(box_x + box_w + 12, box_y + 1),
            arrowprops=dict(arrowstyle="->", color="#dc2626", lw=1.2),
            fontsize=7.5, color="#1e293b", fontweight="bold",
            bbox=dict(boxstyle="round,pad=0.4", facecolor="#fef2f2", edgecolor="#f87171", lw=1))

# Row guide lines
ax.axhline(y=box_y + box_h, xmin=0.15, xmax=0.85, color="#cbd5e1", linestyle="--", lw=0.6)
ax.axhline(y=box_y, xmin=0.15, xmax=0.85, color="#cbd5e1", linestyle="--", lw=0.6)
ax.text(13, box_y + box_h/2, "Row 22\nAddr: 17088", ha="right", va="center", fontsize=7, color="#dc2626", fontweight="bold")

# Memory Calculation Callout Box
ax.text(50, 16, "Word Addressing Formula: Addr = 16384 + (32 × row) + col_word\nEach word = 16 consecutive horizontal pixels\nWriting -1 (1111111111111111) = 16 Black Pixels | Writing 0 = 16 White Pixels",
        ha="center", va="center", fontsize=7.5, color="#0f766e", style="italic",
        bbox=dict(boxstyle="round,pad=0.5", facecolor="#f0fdfa", edgecolor="#99f6e4", lw=1))

# Keyboard Register Box
kbd = patches.FancyBboxPatch((35, 1.5), 30, 3.5, boxstyle="round,pad=0.2", edgecolor="#f59e0b", facecolor="#fffbeb", linewidth=1.2)
ax.add_patch(kbd)
ax.text(50, 3.2, "Keyboard Register RAM[24576] (@KBD): Polled continuously in LOOP", ha="center", va="center", fontsize=7, fontweight="bold", color="#b45309")

plt.tight_layout()
plt.savefig("/home/tushar/personal/capstone/screen_memory_diagram.png", bbox_inches='tight', dpi=300)
plt.close()
print("Diagrams successfully generated!")
