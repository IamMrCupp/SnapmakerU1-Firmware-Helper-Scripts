#!/bin/bash
BINARY="$1"
OUTPUT="${2:-gui-patched}"

if [ ! -f "$BINARY" ]; then
    echo "Usage: $0 <gui-binary> [output-file]"
    exit 1
fi

cp "$BINARY" "$OUTPUT"

echo "=== Checking space after existing strings ==="
# Strings end at 0x31b830 + 16 = 0x31b840
# Let's see what's in the next 512 bytes
xxd "$OUTPUT" | sed -n '0031b840,0031ba40p' | head -20

echo -e "\n=== Available space calculation ==="
# Count consecutive null bytes after last string
xxd "$OUTPUT" | sed -n '0031b840,0031c000p' | grep -m1 -v "0000 0000 0000 0000" || echo "Lots of null space!"

echo -e "\n=== Proposed additions (in order of priority) ==="
echo "1. Panchroma PLA    (13 chars + null = 14 bytes, fits in 16)"
echo "2. Panchroma Matte  (14 chars + null = 15 bytes, fits in 16)" 
echo "3. Panchroma Silk   (13 chars + null = 14 bytes, fits in 16)"
echo "4. PolyLite PLA     (11 chars + null = 12 bytes, fits in 16)"
echo "5. PolyTerra PLA    (12 chars + null = 13 bytes, fits in 16)"
echo "6. PolyMax PLA      (10 chars + null = 11 bytes, fits in 16)"

echo -e "\n=== This would require 6 new strings × 16 bytes = 96 bytes ==="
echo "New strings would go from 0x31b840 to 0x31b8a0"
echo "New pointers would go from 0x615b50 to 0x615b80 (before new NULL at 0x615b88)"
