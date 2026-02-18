#!/bin/bash

BINARY="$1"

echo "=== Space after generic filaments ==="
# Use seek format that works on macOS
xxd -s 0x31b840 -l 128 "$BINARY" | head -8
echo ""
echo "=== What comes after ==="
xxd -s 0x31b8c0 -l 192 "$BINARY"
echo ""
echo "=== Are generics referenced? ==="
xxd "$BINARY" | grep "40 b8 31" | head -3
