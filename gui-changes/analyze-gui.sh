#!/bin/bash

usage() {
    cat << EOF
Usage: $0 <gui-binary>

Analyze the Snapmaker U1 GUI binary structure and locate filament strings.

Arguments:
  gui-binary    Path to the GUI binary file to analyze

What this script does:
  - Displays file type and architecture information
  - Locates Polymaker filament type strings
  - Shows nearby context around filament strings
  - Searches for JSON or config file references

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

echo "=== File Info ==="
file "$BINARY"

echo -e "\n=== Architecture ==="
readelf -h "$BINARY" | grep Machine

echo -e "\n=== Filament Strings ==="
strings -t x "$BINARY" | grep -E "Polylite|PolySonic|PolyTerra"

echo -e "\n=== Nearby Context ==="
strings -n 5 "$BINARY" | grep -B3 -A3 "Polylite PLA"

echo -e "\n=== Check for JSON or config loading ==="
strings "$BINARY" | grep -i "filament.*json\|config.*filament"
