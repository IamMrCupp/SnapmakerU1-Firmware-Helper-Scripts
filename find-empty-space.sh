#!/bin/bash
#!/bin/bash

BINARY="$1"
NEEDED_BYTES=96  # 6 strings × 16 bytes

if [ ! -f "$BINARY" ]; then
    echo "Usage: $0 <path-to-gui-binary>"
    exit 1
fi

echo "=== Searching for $NEEDED_BYTES consecutive zero bytes ==="
echo ""

# Convert binary to hex and search for long runs of zeros
# We're looking for at least 96 bytes (0x60) of zeros
xxd "$BINARY" | awk '
BEGIN {
    zero_start = ""
    zero_count = 0
    found = 0
}
{
    # Extract the hex values (columns 2-9)
    hex_data = ""
    for (i = 2; i <= 9; i++) {
        hex_data = hex_data $i
    }
    
    # Check if this line is all zeros
    if (hex_data ~ /^0+$/) {
        if (zero_count == 0) {
            zero_start = $1
        }
        zero_count += 16
    } else {
        # If we had a run of zeros, check if it was big enough
        if (zero_count >= 96 && found < 5) {
            print "Found " zero_count " zero bytes starting at 0x" zero_start
            found++
        }
        zero_count = 0
        zero_start = ""
    }
}
END {
    # Check final run
    if (zero_count >= 96 && found < 5) {
        print "Found " zero_count " zero bytes starting at 0x" zero_start
    }
    if (found == 0) {
        print "No suitable empty space found (need 96 consecutive zero bytes)"
    }
}
'

echo ""
echo "=== Checking data section alignment ==="
# Look at the section headers to find good locations
greadelf -S "$BINARY" | grep -E '\.data|\.bss|\.rodata' | head -20

BINARY="$1"
NEEDED_BYTES=96  # 6 strings × 16 bytes

if [ ! -f "$BINARY" ]; then
    echo "Usage: $0 <path-to-gui-binary>"
    exit 1
fi

echo "=== Searching for $NEEDED_BYTES consecutive zero bytes ==="
echo ""

# Convert binary to hex and search for long runs of zeros
# We're looking for at least 96 bytes (0x60) of zeros
xxd "$BINARY" | awk '
BEGIN {
    zero_start = ""
    zero_count = 0
    found = 0
}
{
    # Extract the hex values (columns 2-9)
    hex_data = ""
    for (i = 2; i <= 9; i++) {
        hex_data = hex_data $i
    }
    
    # Check if this line is all zeros
    if (hex_data ~ /^0+$/) {
        if (zero_count == 0) {
            zero_start = $1
        }
        zero_count += 16
    } else {
        # If we had a run of zeros, check if it was big enough
        if (zero_count >= 96 && found < 5) {
            print "Found " zero_count " zero bytes starting at 0x" zero_start
            found++
        }
        zero_count = 0
        zero_start = ""
    }
}
END {
    # Check final run
    if (zero_count >= 96 && found < 5) {
        print "Found " zero_count " zero bytes starting at 0x" zero_start
    }
    if (found == 0) {
        print "No suitable empty space found (need 96 consecutive zero bytes)"
    }
}
'

echo ""
echo "=== Checking data section alignment ==="
# Look at the section headers to find good locations
readelf -S "$BINARY" | grep -E '\.data|\.bss|\.rodata' | head -20
