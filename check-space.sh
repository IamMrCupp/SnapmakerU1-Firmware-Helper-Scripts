#!/bin/bash
BINARY="$1"

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
