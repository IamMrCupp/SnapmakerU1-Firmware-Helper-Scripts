#!/bin/bash
BINARY="$1"

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
