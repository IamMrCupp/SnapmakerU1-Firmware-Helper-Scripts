#!/bin/bash

usage() {
    cat << EOF
Usage: $0 <gui-binary>

Verify available space for new strings and pointers in the GUI binary.

Arguments:
  gui-binary    Path to the GUI binary file to check

What this script does:
  - Checks space after existing filament strings (0x31b840)
  - Examines pointer array area for available space (0x615b50)
  - Verifies string boundaries and null padding
  - Confirms safe regions for patching

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

echo "=== Checking space after existing strings ==="
# Strings end at 0x31b830 + 16 = 0x31b840
# Convert hex to decimal: 0x31b840 = 3258432
xxd "$BINARY" | awk '$1 ~ /^0031b8[4-9a-f]/ || $1 ~ /^0031b9/ || $1 ~ /^0031ba/ {print; count++; if(count>20) exit}'

echo -e "\n=== Checking pointer array area for space ==="
# After 0x615b50 (where new pointers would go)
xxd "$BINARY" | awk '$1 ~ /^00615b[5-9a-f]/ || $1 ~ /^00615[c-f]/ {print; count++; if(count>10) exit}'

echo -e "\n=== Verifying string boundaries ==="
echo "Last existing string at 0x31b830 (Polylite PETG):"
xxd "$BINARY" | grep "^0031b830:"
echo "Next 3 lines after strings:"
xxd "$BINARY" | awk '$1 == "0031b840:" || $1 == "0031b850:" || $1 == "0031b860:" {print}'
