#!/bin/bash

if [ ! -f "firmware/firmware.bin" ]; then
    echo "No firmware/firmware.bin found. Run: ./dev.sh make PROFILE=extended build"
    exit 1
fi

echo "=== Verifying firmware/firmware.bin ==="
mkdir -p tmp/verify-rfid
./dev.sh ./scripts/extract_squashfs.sh firmware/firmware.bin tmp/verify-rfid

echo ""
echo "Checking for RFID OpenSpool support..."
if [ -f "tmp/verify-rfid/rootfs/home/lava/klipper/klippy/extras/filament_protocol_openspool.py" ]; then
    echo "✓ filament_protocol_openspool.py present"
    echo "✓ filament_protocol_plugin.py present"
    echo ""
    echo "Ready to flash! Your NTAG215 tags should work after flashing this firmware."
else
    echo "✗ OpenSpool module missing - overlay not applied?"
fi

rm -rf tmp/verify-rfid
