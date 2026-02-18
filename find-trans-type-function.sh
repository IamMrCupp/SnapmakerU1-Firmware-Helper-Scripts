#!/bin/bash

BINARY="$1"

echo "=== Finding trans_type function ==="
echo ""

# Find the string "trans_type" and get its offset
trans_type_offset=$(strings -t x "$BINARY" | grep "^[0-9a-f]* trans_type$" | head -1 | awk '{print $1}')

if [ -n "$trans_type_offset" ]; then
    echo "Found 'trans_type' string at offset: 0x$trans_type_offset"
    
    # Convert to address (add load base)
    trans_type_addr=$((0x$trans_type_offset))
    echo "String address: 0x$(printf '%x' $trans_type_addr)"
    
    # Find references to this string in the binary
    echo ""
    echo "=== Looking for references to 'trans_type' string ==="
    
    # Search for little-endian pointer to this address
    # Split address into bytes (little-endian)
    byte1=$(printf '%02x' $((trans_type_addr & 0xff)))
    byte2=$(printf '%02x' $(((trans_type_addr >> 8) & 0xff)))
    byte3=$(printf '%02x' $(((trans_type_addr >> 16) & 0xff)))
    byte4=$(printf '%02x' $(((trans_type_addr >> 24) & 0xff)))
    
    echo "Searching for pointer pattern: $byte1 $byte2 $byte3 $byte4"
    xxd "$BINARY" | grep -i "$byte1 *$byte2 *$byte3 *$byte4" | head -5
fi

echo ""
echo "=== Checking pointer array usage with objdump ==="
# Try to find any function that loads from 0x615b20
objdump -d "$BINARY" 2>/dev/null | grep -B 20 -A 10 "615b20" | head -60

echo ""
echo "=== Alternative: Search for loop patterns iterating pointer array ==="
# ARM64 pattern: adrp + add to form address, then ldr in a loop
objdump -d "$BINARY" --start-address=$((0x615b20 - 0x200000)) --stop-address=$((0x615b20 + 0x10000)) 2>/dev/null | \
  grep -E "(adrp|ldr.*\[x.*#)" | head -30
