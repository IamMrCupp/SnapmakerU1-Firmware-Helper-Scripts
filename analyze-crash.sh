#!/bin/bash

echo "=== Comparing address ranges ==="
echo "Original strings: 0x31b7f0 - 0x31b830 (in .rodata high)"
echo "New strings:      0x1b7e80 - 0x1b7ed0 (in .rodata low)"
echo ""
echo "This address difference might be the problem."
echo "The code might expect all strings in a specific range."
echo ""
echo "Let's check what's at 0x31b840 onward (after original strings):"
xxd ~/Code/SnapmakerU1-Extended-Firmware/tmp/extracted/rootfs/bin/gui -s 0x31b840 -l 192
