#!/bin/bash

BINARY="$1"

echo "=== Searching for pointer array references in binary ==="
echo ""

# The pointer array is at 0x615b20
# In ARM64 ADRP+ADD pattern, the address is split:
# ADRP loads page address (0x615000)
# ADD adds offset (0xb20)

# Search for the full address pattern in little-endian
echo "Method 1: Direct address references (0x615b20):"
xxd "$BINARY" | grep -E "20 5b 61 00|205b6100" | head -10

echo ""
echo "Method 2: Looking for page address 0x615000 (for ADRP instruction):"
# In ADRP, the page address might be encoded differently
# Just search for any reference to addresses near our pointer array
xxd "$BINARY" | awk '$1 ~ /0061[45]/ { print }' | grep -E "5b|61" | head -10

echo ""
echo "Method 3: Check what functions reference data near 0x615b20:"
# Look at the PLT/GOT section which might reference this area
readelf -r "$BINARY" | grep -E "61[45]"

echo ""
echo "=== Let's just test the patched binary! ==="
echo "The easiest way to verify if there's a hardcoded counter is to:"
echo "1. Test the patched binary on the printer"
echo "2. If only 5 profiles show, we'll search for the counter value"
echo "3. If 11 profiles show (6 old + 5 original), success!"
echo ""
echo "The pointer array now has 12 entries total (6 original + 6 new),"
echo "so if the code iterates until NULL, it should work."
