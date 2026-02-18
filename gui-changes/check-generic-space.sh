#!/bin/bash

usage() {
    cat << EOF
Usage: $0 <gui-binary>

Check space after generic filament strings for potential use.

Arguments:
  gui-binary    Path to the GUI binary file to check

What this script does:
  - Examines memory space after generic filaments (0x31b840)
  - Shows what data comes after the string section
  - Checks if generic strings are referenced elsewhere
  - Helps identify safe insertion points

Example:
  $0 /path/to/gui

EOF
    exit 1
}

BINARY="$1"

if [ -z "$BINARY" ] || [ ! -f "$BINARY" ]; then
    usage
fi

echo "=== Space after generic filaments ==="
# Use seek format that works on macOS
xxd -s 0x31b840 -l 128 "$BINARY" | head -8
echo ""
echo "=== What comes after ==="
xxd -s 0x31b8c0 -l 192 "$BINARY"
echo ""
echo "=== Are generics referenced? ==="
xxd "$BINARY" | grep "40 b8 31" | head -3
