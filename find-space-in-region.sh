#!/bin/bash

BINARY="$1"

echo "=== Searching for 96+ consecutive zeros in 0x31b000-0x31d000 region ==="
echo ""

xxd "$BINARY" | awk '
BEGIN {
    target_start = 0x31b000
    target_end = 0x31d000
    zero_start = ""
    zero_count = 0
    found_count = 0
}
{
    # Get the address
    addr_str = $1
    gsub(/:/, "", addr_str)
    addr = strtonum("0x" addr_str)
    
    # Check if in target range
    if (addr < target_start || addr >= target_end) next
    
    # Extract hex bytes
    hex_data = ""
    for (i = 2; i <= 9; i++) {
        hex_data = hex_data $i
    }
    
    # Check if all zeros
    if (hex_data ~ /^0+$/) {
        if (zero_count == 0) {
            zero_start = addr_str
        }
        zero_count += 16
    } else {
        # Print if we found a good chunk
        if (zero_count >= 96 && found_count < 3) {
            printf "Found %d zero bytes at 0x%s\n", zero_count, zero_start
            found_count++
        }
        zero_count = 0
    }
}
END {
    if (zero_count >= 96 && found_count < 3) {
        printf "Found %d zero bytes at 0x%s\n", zero_count, zero_start
    }
    if (found_count == 0) {
        print "No 96+ byte zero regions found in 0x31b000-0x31d000"
        print ""
        print "Alternative: We could OVERWRITE unused filament types"
        print "Or expand the binary to add more space"
    }
}
'

echo ""
echo "=== Alternative: Check end of .rodata section ==="
readelf -S "$BINARY" 2>/dev/null | grep rodata
