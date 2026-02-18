#!/bin/bash

usage() {
    cat << EOF
Usage: $0 <gui-binary>

Search for long zero runs in specific memory regions (0x31b000-0x31d000).

Arguments:
  gui-binary    Path to the GUI binary file to search

What this script does:
  - Scans the 0x31b000-0x31d000 region for empty space
  - Reports consecutive zero byte runs >= 96 bytes
  - Identifies safe memory regions near existing strings
  - Provides addresses suitable for string injection

Example:
  $0 /path/to/gui

EOF
    exit 1
}

BINARY="$1"

if [ -z "$BINARY" ] || [ ! -f "$BINARY" ]; then
    usage
fi

echo "=== Searching for long zero runs in 0x31b000-0x31d000 region ==="
echo ""

# Simpler approach that works on macOS awk
xxd "$BINARY" | grep "^0031[bcd]" | awk '
BEGIN {
    zero_start = ""
    zero_count = 0
    prev_was_zero = 0
}
{
    addr = $1
    # Check if line is all zeros (columns 2-9 should be all zeros)
    hex_line = $2 $3 $4 $5 $6 $7 $8 $9
    is_zero = (hex_line ~ /^0+$/)
    
    if (is_zero) {
        if (!prev_was_zero) {
            zero_start = addr
            zero_count = 0
        }
        zero_count += 16
        prev_was_zero = 1
    } else {
        if (prev_was_zero && zero_count >= 96) {
            print "Found " zero_count " zero bytes at " zero_start
        }
        prev_was_zero = 0
        zero_count = 0
    }
}
END {
    if (prev_was_zero && zero_count >= 96) {
        print "Found " zero_count " zero bytes at " zero_start
    }
}
'

echo ""
echo "=== Reality check: Do we actually NEED 11 profiles on touchscreen? ==="
echo "Given the space constraints, we could:"
echo "1. REPLACE the existing 5 Polymaker strings with our preferred 5"
echo "2. Keep the other 7 profiles accessible only via web interface"
echo ""
echo "Current 5 strings:"
strings "$BINARY" | grep -A 5 "Polylite PLA" | head -6
echo ""
echo "Which 5 should we prioritize for touchscreen?"
