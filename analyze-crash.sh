#!/bin/bash

usage() {
    cat << EOF
Usage: $0 <gui-binary>

Analyze address ranges to diagnose crashes and validate memory regions.

Arguments:
  gui-binary    Path to the GUI binary file to analyze

What this script does:
  - Compares original and new string address ranges
  - Identifies potential address validation issues
  - Examines memory space after original strings
  - Suggests strategies for safe memory regions

Example:
  $0 /path/to/gui
  $0 output/gui-patched

EOF
    exit 1
}

BINARY="$1"

if [ -z "$BINARY" ] || [ ! -f "$BINARY" ]; then
    usage
fi

echo "=== Address range comparison ==="
echo "Original strings: 0x31b7f0 - 0x31b830 (all in same region)"
echo "New strings:      0x1b7e80 - 0x1b7ed0 (DIFFERENT region - this is the problem!)"
echo ""
echo "The code likely validates addresses are in a specific range."
echo ""
echo "=== What's at 0x31b840 (right after original strings) ==="
xxd "$BINARY" | awk '$1 ~ /^0031b8[4-9a-f]/ || $1 ~ /^0031b9/ || $1 ~ /^0031ba/' | head -12
echo ""
echo "=== Strategy: We need to use the space starting at a higher offset ==="
echo "Let's search for usable space AFTER 0x31b900:"
xxd "$BINARY" | awk '$1 ~ /^0031b9/ || $1 ~ /^0031ba/ || $1 ~ /^0031bb/' | head -20
