#!/usr/bin/env python3
"""
Binary patcher for Snapmaker U1 GUI to add additional Polymaker filament profiles.
Injects 6 new filament type strings and updates the pointer array.
"""

import sys
import struct
from pathlib import Path

# Configuration
NEW_STRINGS_OFFSET = 0x1b7e80  # Empty space in .rodata section
POINTER_ARRAY_OFFSET = 0x615b50  # Where to add new pointers (after existing NULL)

# New filament profile strings (max 15 chars + null terminator = 16 bytes each)
NEW_PROFILES = [
    "Panchroma PLA",      # 0x1b7e80
    "Panchroma Matte",   # 0x1b7e90
    "Panchroma Silk",    # 0x1b7ea0
    "PolyLite PLA",      # 0x1b7eb0
    "PolyMax PLA",       # 0x1b7ec0
    "PolyMax PETG",      # 0x1b7ed0
]

def patch_binary(input_path, output_path):
    """Patch the GUI binary to add new filament profiles."""
    
    print(f"Reading binary from: {input_path}")
    with open(input_path, 'rb') as f:
        data = bytearray(f.read())
    
    print(f"Binary size: {len(data)} bytes")
    
    # Step 1: Write new strings to empty space
    print(f"\n=== Writing {len(NEW_PROFILES)} new strings at 0x{NEW_STRINGS_OFFSET:08x} ===")
    for i, profile in enumerate(NEW_PROFILES):
        offset = NEW_STRINGS_OFFSET + (i * 16)
        
        # Ensure string fits in 16 bytes (15 chars + null)
        if len(profile) > 15:
            print(f"ERROR: String '{profile}' is too long ({len(profile)} chars, max 15)")
            return False
        
        # Create 16-byte padded string
        string_bytes = profile.encode('ascii') + b'\x00' * (16 - len(profile))
        
        # Verify we're writing to zeros
        existing = data[offset:offset+16]
        if existing != b'\x00' * 16:
            print(f"WARNING: Offset 0x{offset:08x} is not empty!")
            print(f"  Existing data: {existing.hex()}")
        
        # Write the string
        data[offset:offset+16] = string_bytes
        print(f"  [{i+1}] 0x{offset:08x}: {profile}")
    
    # Step 2: Update pointer array
    print(f"\n=== Updating pointer array at 0x{POINTER_ARRAY_OFFSET:08x} ===")
    
    # Verify pointer array location is empty (should be NULL terminator)
    existing_pointers = data[POINTER_ARRAY_OFFSET:POINTER_ARRAY_OFFSET+8]
    if existing_pointers != b'\x00' * 8:
        print(f"WARNING: Pointer array location not empty: {existing_pointers.hex()}")
    
    # Write new pointers (little-endian 64-bit addresses)
    for i, profile in enumerate(NEW_PROFILES):
        ptr_offset = POINTER_ARRAY_OFFSET + (i * 8)
        string_addr = NEW_STRINGS_OFFSET + (i * 16)
        
        # Pack as little-endian 64-bit pointer
        pointer_bytes = struct.pack('<Q', string_addr)
        data[ptr_offset:ptr_offset+8] = pointer_bytes
        
        print(f"  [{i+1}] 0x{ptr_offset:08x}: -> 0x{string_addr:08x} ({profile})")
    
    # Write NULL terminator after new pointers
    null_offset = POINTER_ARRAY_OFFSET + (len(NEW_PROFILES) * 8)
    data[null_offset:null_offset+8] = b'\x00' * 8
    print(f"  [NULL] 0x{null_offset:08x}: -> 0x00000000")
    
    # Step 3: Verify existing pointer array wasn't corrupted
    print(f"\n=== Verifying existing pointers at 0x615b20 ===")
    existing_ptr_base = 0x615b20
    expected_strings = [
        (0x31b7e0, "mystery"),
        (0x31b7f0, "Polylite PLA"),
        (0x31b800, "PolySonic PLA"),
        (0x31b810, "PolyTerra PLA"),
        (0x31b820, "Polylite ABS"),
        (0x31b830, "Polylite PETG"),
    ]
    
    for i, (expected_addr, name) in enumerate(expected_strings):
        ptr_offset = existing_ptr_base + (i * 8)
        ptr_value = struct.unpack('<Q', data[ptr_offset:ptr_offset+8])[0]
        status = "✓" if ptr_value == expected_addr else "✗"
        print(f"  {status} 0x{ptr_offset:08x}: -> 0x{ptr_value:08x} (expected 0x{expected_addr:08x})")
    
    # Step 4: Write patched binary
    print(f"\n=== Writing patched binary to: {output_path} ===")
    with open(output_path, 'wb') as f:
        f.write(data)
    
    print(f"✓ Successfully patched binary!")
    print(f"\nNext steps:")
    print(f"  1. Copy to printer: scp {output_path} root@snapmaker-u1:/tmp/gui-patched")
    print(f"  2. Backup original: ssh root@snapmaker-u1 'cp /usr/bin/gui /usr/bin/gui.bak'")
    print(f"  3. Test: ssh root@snapmaker-u1 'killall gui && /tmp/gui-patched'")
    
    return True

def main():
    if len(sys.argv) != 3:
        print("Usage: patch-gui-binary.py <input-gui-binary> <output-gui-binary>")
        print("\nExample:")
        print("  ./patch-gui-binary.py tmp/extracted/rootfs/bin/gui tmp/gui-patched")
        sys.exit(1)
    
    input_path = Path(sys.argv[1])
    output_path = Path(sys.argv[2])
    
    if not input_path.exists():
        print(f"ERROR: Input file not found: {input_path}")
        sys.exit(1)
    
    if output_path.exists():
        print(f"WARNING: Output file already exists: {output_path}")
        response = input("Overwrite? (y/N): ")
        if response.lower() != 'y':
            print("Aborted.")
            sys.exit(0)
    
    success = patch_binary(input_path, output_path)
    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()
