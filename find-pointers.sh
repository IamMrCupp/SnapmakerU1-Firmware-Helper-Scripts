#!/bin/bash
BINARY="$1"

echo "=== Looking for pointer array to filament strings ==="
# The addresses in little-endian format
# 31b7f0 = f0 b7 31 00 00 00 00 00
# 31b800 = 00 b8 31 00 00 00 00 00
# etc.

# Search for the pointer sequence
xxd "$BINARY" | grep -B2 -A10 "f0b7 3100"

echo -e "\n=== Check how many times each string is referenced ==="
for addr in 31b7f0 31b800 31b810 31b820 31b830; do
    # Convert to little-endian search pattern
    echo "Searching for pointer to $addr:"
    # For ARM64, pointers are 8 bytes
    count=$(xxd "$BINARY" | grep -c "${addr:4:2}${addr:2:2} ${addr:0:2}00")
    echo "  Found $count references"
done

echo -e "\n=== Looking for array size/count (value 5) near pointers ==="
xxd "$BINARY" | grep -B5 -A5 "f0b7 3100" | grep "0500 0000"
