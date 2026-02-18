#!/bin/bash

usage() {
    cat << 'USAGE_EOF'
Usage: $0 <ssh-host>

Test both Snapmaker RFID and NTAG215 OpenSpool tags.

Arguments:
  ssh-host    Hostname or IP address of the printer (e.g., snapmaker-u1 or 192.168.1.100)

Environment Variables:
  PASSWORD    SSH password for root user (default: snapmaker)

Examples:
  # Test RFID reading on your printer
  $0 snapmaker-u1

  # Use custom password
  PASSWORD=mypassword $0 192.168.1.100

What this script does:
  1. Verifies OpenSpool module is installed
  2. Checks Klipper status
  3. Tests Slot 2 (Snapmaker RFID - baseline test)
  4. Tests Slot 3 (NTAG215 OpenSpool tag)
  5. Analyzes logs for:
     - ATQA: 0x44 0x00 = NTAG215 detected
     - NDEF RFID data = Tag being read
     - OpenSpool JSON payload = JSON parsed
     - wakeup err: -20 = Communication failure

Requirements:
  - sshpass installed (brew install sshpass on macOS)
  - Network access to printer on port 7125 (Moonraker API)
  - Root SSH access enabled on printer
USAGE_EOF
    exit 1
}

SSH_HOST="$1"

if [ -z "$SSH_HOST" ]; then
    usage
fi

PASSWORD="${PASSWORD:-snapmaker}"
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"

# Check for sshpass
if ! command -v sshpass &> /dev/null; then
    echo "Error: sshpass not found. Install with: brew install sshpass"
    exit 1
fi

# Wrapper for SSH commands
ssh_exec() {
    sshpass -p "$PASSWORD" ssh $SSH_OPTS root@"$SSH_HOST" "$@"
}

echo "=== Testing Both RFID Slots on $SSH_HOST ==="
echo "Slot 2: Snapmaker RFID (should work)"
echo "Slot 3: NTAG215 OpenSpool (testing)"
echo ""

echo "1. Verify OpenSpool module installed..."
ssh_exec 'ls -lh /home/lava/klipper/klippy/extras/filament_protocol_*.py'

echo ""
echo "2. Check current Klipper status..."
ssh_exec 'systemctl status klipper | head -5'

echo ""
echo "=== Testing Slot 2 (Snapmaker RFID) ==="
echo "Triggering read..."
curl -s "http://$SSH_HOST:7125/printer/gcode/script?script=FILAMENT_DT_UPDATE%20CHANNEL=2"
sleep 3

echo ""
echo "Result:"
ssh_exec 'tail -50 /home/lava/printer_data/logs/klippy.log | grep -A 10 "channel\[2\]"'

echo ""
echo "=== Testing Slot 3 (NTAG215) ==="
echo "Triggering read..."
curl -s "http://$SSH_HOST:7125/printer/gcode/script?script=FILAMENT_DT_UPDATE%20CHANNEL=3"
sleep 3

echo ""
echo "Full recent log output:"
ssh_exec 'tail -100 /home/lava/printer_data/logs/klippy.log'

echo ""
echo "=== Checking for NDEF/OpenSpool import errors ==="
ssh_exec 'grep -i "error.*openspool\|import.*openspool\|traceback" /home/lava/printer_data/logs/klippy.log | tail -20'

echo ""
echo "=== Analysis ==="
echo "If you see 'wakeup err: -20', try repositioning the tag closer to the reader."
echo "If OpenSpool module is missing, rebuild firmware with: ./dev.sh make PROFILE=extended build"