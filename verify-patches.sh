#!/bin/bash

usage() {
    cat << EOF
Usage: $0 <patched-binary>

Verify patched binary structure, strings, and pointers are correct.

Arguments:
  patched-binary    Path to the patched GUI binary to verify

What this script does:
  - Checks that new strings are present
  - Verifies pointer array structure
  - Validates new string locations in memory
  - Confirms addresses are in valid sections
  - Checks for running GUI processes

Example:
  $0 output/gui-patched
  $0 /tmp/gui-test

Requirements:
  - greadelf (GNU readelf, install via: brew install binutils)

EOF
    exit 1
}

BINARY="$1"

if [ -z "$BINARY" ] || [ ! -f "$BINARY" ]; then
    usage
fi

echo "=== Verifying patched binary structure ==="
echo ""

echo "1. Check new strings are present:"
strings "$BINARY" | grep -E "Panchroma|PolyMax"

echo ""
echo "2. Verify new pointer array:"
echo "   Existing pointers (should be unchanged):"
xxd -s 0x615b20 -l 48 "$BINARY"

echo ""
echo "   New pointers (should point to 0x1b7e80 range):"
xxd -s 0x615b50 -l 56 "$BINARY"

echo ""
echo "3. Verify new strings location:"
xxd -s 0x1b7e80 -l 96 "$BINARY"

echo ""
echo "4. Check if addresses are in valid sections:"
greadelf -S "$BINARY" | grep -A 1 -E "\.rodata|\.data"

echo ""
echo "=== Checking if we need to run GUI differently ==="
ps aux | grep "[g]ui" || echo "No GUI process running"
