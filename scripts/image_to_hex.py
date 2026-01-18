import cv2
import numpy as np

# 1. Settings
INPUT_IMAGE = "../photos/lenna.jpeg"
OUTPUT_FILE = "image_rom.hex"
TARGET_W = 221  # Resize to fit in FPGA Block RAM
TARGET_H = 221

def convert_to_hex():
    # 2. Load Image
    img = cv2.imread(INPUT_IMAGE)
    
    if img is None:
        print("Error: Could not load image.")
        return

    # 3. Resize and Grayscale
    # We resize first to ensure it fits in the FPGA
    img = cv2.resize(img, (TARGET_W, TARGET_H))
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # 4. Write to Hex File
    # Gowin .mi format usually accepts raw hex values, one per line
    with open(OUTPUT_FILE, 'w') as f:
        # Add header comments if you like (optional)
        f.write(f"# Image dimensions: {TARGET_W}x{TARGET_H}\n")
        f.write("# Format: Hex\n")
        f.write("# Depth: " + str(TARGET_W * TARGET_H) + "\n")
        f.write("# Width: 8\n")
        
        # Flatten the 2D array to a 1D list of pixels
        pixels = gray.flatten()
        
        for p in pixels:
            # Convert integer to 2-digit hex (e.g., 255 -> FF, 10 -> 0A)
            hex_val = "{:02X}".format(p)
            f.write(hex_val + "\n")

    print(f"Success! Saved {TARGET_W}x{TARGET_H} image to {OUTPUT_FILE}")
    print(f"Total Bytes: {len(pixels)}")

if __name__ == "__main__":
    convert_to_hex()