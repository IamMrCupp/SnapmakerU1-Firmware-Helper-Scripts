#!/bin/bash

usage() {
    cat << EOF
Usage: $0 <gui-binary>

Search for loop counter patterns that iterate over filament arrays.

Arguments:
  gui-binary    Path to the GUI binary file to search

What this script does:
  - Finds references to pointer array (0x615b20)
  - Disassembles code around pointer references
  - Identifies loop bounds and iteration patterns
  - Helps understand how many array elements are expected

Example:
  $0 /path/to/gui

Requirements:
  - objdump (part of binutils)

EOF
    exit 1
}

BINARY="$1"

if [ -z "$BINARY" ] || [ ! -f "$BINARY" ]; then
    usage
fi

echo "=== Searching for pointer array references and potential loop counters ==="
echo ""

# Find references to the pointer array base address (0x615b20)
echo "Looking for references to pointer array at 0x615b20..."
xxd "$BINARY" | grep -E "20 ?5b ?61|615b20" | head -10

echo ""
echo "=== Disassembling area around pointer references ==="
echo "This shows assembly code that might contain loop bounds"
echo ""

# Use objdump to show disassembly around known pointer references
# We saw earlier that each pointer is referenced twice
objdump -d "$BINARY" --start-address=0x13e000 --stop-address=0x140000 2>/dev/null | \
  grep -A 5 -B 5 "615b" | head -40

echo ""
echo "=== Looking for immediate values 5 or 6 near pointer usage ==="
# In ARM64, immediate values are encoded in instructions
# Look for comparisons like "cmp x0, #5" or "cmp x0, #6"
objdump -d "$BINARY" 2>/dev/null | grep -E "(cmp|mov).*#[56]" | grep -v "0x5\|0x6" | head -20
