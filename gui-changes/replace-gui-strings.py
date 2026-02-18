#!/usr/bin/env python3
"""
Replace existing 5 Polymaker strings with preferred profiles (in-place).
All 12 profiles still work in Klipper/web interface.
"""

import sys
from pathlib import Path

# Original strings and their offsets
REPLACEMENTS = [
    (0x31b7f0, "Polylite PLA",   "Panchroma PLA"),      # Most popular
    (0x31b800, "PolySonic PLA",  "Panchroma Matte"),    # Matte finish
    (0x31b810, "PolyTerra PLA",  "Panchroma Silk"),     # Silk finish  
    (0x31b820, "Polylite ABS",   "PolyMax PLA"),        # Premium PLA
    (0x31b830, "Polylite PETG",  "PolyMax PETG"),       # Premium PETG
]

def print_usage():
    """Print detailed usage information."""
    print("""
Usage: replace-gui-strings.py <input-gui> <output-gui>

Replace existing Polymaker filament profiles with custom ones (in-place method).

Arguments:
  input-gui     Path to the original GUI binary file
  output-gui    Path where patched binary will be written

What this script does:
  - Validates input binary and string locations
  - Replaces 5 existing Polymaker strings in-place
  - Preserves all other binary data unchanged
  - Creates patched binary with updated profiles

Replacements made:
""")
    for _, old, new in REPLACEMENTS:
        print(f"  '{old}' → '{new}'")
    
    print("""
Examples:
  ./replace-gui-strings.py /path/to/gui output/gui-patched
  ./replace-gui-strings.py tmp/gui /tmp/gui-test

Advantages of this method:
  - More stable than injection method
  - No address range validation issues
  - All 12 profiles still work in Klipper/web interface
  - Safer and more reliable patching approach

Note: This replaces existing profiles in the GUI dropdown, but all
original profiles remain functional via Klipper configuration.
""")

def replace_strings(input_path, output_path):
    """Replace the 5 Polymaker strings in the GUI binary."""
    
    print(f"Reading: {input_path}")
    with open(input_path, 'rb') as f:
        data = bytearray(f.read())
    
    print(f"\n=== Replacing 5 Polymaker profile strings ===\n")
    
    for offset, old_str, new_str in REPLACEMENTS:
        # Verify old string is present
        existing = data[offset:offset+len(old_str)+1]
        expected = old_str.encode('ascii') + b'\x00'
        
        if not existing.startswith(expected):
            print(f"WARNING: Expected '{old_str}' at 0x{offset:08x}")
            print(f"  Found: {existing[:20]}")
            continue
        
        # Ensure new string fits (max 15 chars + null = 16 bytes)
        if len(new_str) > 15:
            print(f"ERROR: '{new_str}' too long ({len(new_str)} > 15 chars)")
            return False
        
        # Write new string (padded with nulls to 16 bytes)
        new_bytes = new_str.encode('ascii') + b'\x00' * (16 - len(new_str))
        data[offset:offset+16] = new_bytes
        
        print(f"✓ 0x{offset:08x}: '{old_str}' → '{new_str}'")
    
    print(f"\n=== Writing patched binary: {output_path} ===")
    with open(output_path, 'wb') as f:
        f.write(data)
    
    print("✓ Success!")
    print("\nThese 5 will show on touchscreen. All 12 profiles still work via web interface.")
    return True

if __name__ == '__main__':
    if len(sys.argv) != 3 or (len(sys.argv) == 2 and sys.argv[1] in ['-h', '--help', 'help']):
        print_usage()
        sys.exit(0 if len(sys.argv) == 2 else 1)
    
    input_path = Path(sys.argv[1])
    output_path = Path(sys.argv[2])
    
    if not input_path.exists():
        print(f"ERROR: {input_path} not found")
        sys.exit(1)
    
    success = replace_strings(input_path, output_path)
    sys.exit(0 if success else 1)
