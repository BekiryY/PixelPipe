import re
from pathlib import Path

# Configuration
hex_path = Path(r"image_rom.hex")
out_path_core = Path(r"..\\fpga\\IMG_FILTER_DISPLAY\\src\\prom")
out_path = out_path_core.with_suffix(".mi")
DEPTH = 3758  # Address Depth
WIDTH = 13*8  # Data Width in bits

all_hex_chars = ""

print(f"Reading {hex_path}...")

# 1. Read all lines and strip out spaces, newlines, and non-hex chars
try:
    with open(hex_path, 'r') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('@'):
                continue

            # Remove all non-hex characters
            cleaned_line = re.sub(r'[^0-9a-fA-F]', '', line)
            all_hex_chars += cleaned_line
except FileNotFoundError:
    print(f"Error: Could not find file {hex_path}")
    exit()

print(f"Total hex characters read: {len(all_hex_chars)}")

# 2. Write the .mi file in the correct Gowin format
with open(out_path, "w") as f:
    # --- New Header Format ---
    f.write("#File_format=Hex\n")
    f.write(f"#Address_depth={DEPTH}\n")
    f.write(f"#Data_width={WIDTH}\n")

    # You requested this tag. Note: Some versions of Gowin
    # just expect raw hex without this line, but if your
    # specific IP requires it, keep it.
    f.write("#CONTENT BEGIN\n")

    addr = 0
    chars_per_word = WIDTH // 4  # 32 bits = 8 hex chars

    # 3. Pack the hex string into chunks
    for i in range(0, len(all_hex_chars), chars_per_word):
        if addr >= DEPTH:
            print(f"Warning: Data exceeds DEPTH ({DEPTH}). Truncating.")
            break

        word = all_hex_chars[i:i + chars_per_word]

        # Handle partial words at the end of file
        if len(word) < chars_per_word:
            word = word.ljust(chars_per_word, '0')

            # --- New Body Format: Just the data, no address prefix ---
        f.write(f"{word.upper()}\n")
        addr += 1

    # 4. Pad the rest with zeros
    print(f"Padding remaining words with zeros...")
    zero_word = "0" * chars_per_word

    while addr < DEPTH:
        f.write(f"{zero_word}\n")
        addr += 1

print(f"Successfully created: {out_path}")