#!/bin/bash

usage() {
    cat << EOF
Usage: $0 <ssh-host> <profile>

Debug RFID/NFC functionality on Snapmaker U1 printer.

Arguments:
  ssh-host    Hostname or IP address of the printer (e.g., snapmaker-u1 or 192.168.1.100)
  profile     Profile name (currently unused, reserved for future use)

Environment Variables:
  PASSWORD    SSH password for root user (default: snapmaker)

Examples:
  # Debug RFID on your printer
  $0 snapmaker-u1 default

  # Use custom password
  PASSWORD=mypassword $0 192.168.1.100 default

What this script checks:
  1. RFID overlay presence in firmware
  2. Klipper logs for RFID activity
  3. Current filament detection configuration
  4. Manual RFID read test (Channel 3)
  5. Recent RFID card data parsing

Requirements:
  - sshpass must be installed (brew install sshpass on macOS)
  - Network access to the printer
  - Root SSH access enabled on printer

EOF
    exit 1
}

SSH_HOST="$1"
PROFILE="$2"
shift 2

if [ -z "$SSH_HOST" ]; then
    usage
fi

PASSWORD="${PASSWORD:-snapmaker}"
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

echo "=== RFID/NFC Debugging for Snapmaker U1 ==="
echo "Host: $SSH_HOST"
echo ""

echo "1. Checking if RFID overlay is active in firmware..."
sshpass -p "$PASSWORD" ssh $SSH_OPTS root@$SSH_HOST 'ls -la /home/lava/klipper/klippy/extras/filament_protocol_openspool.py 2>/dev/null && echo "✓ OpenSpool module found" || echo "✗ OpenSpool module NOT found (overlay not applied?)"'

echo ""
echo "2. Checking Klipper logs for RFID activity..."
sshpass -p "$PASSWORD" ssh $SSH_OPTS root@$SSH_HOST 'tail -100 /home/lava/printer_data/logs/klippy.log | grep -E "RFID|NTAG|NDEF|channel.*card|filament_detect"'

echo ""
echo "3. Current filament detection status..."
sshpass -p "$PASSWORD" ssh $SSH_OPTS root@$SSH_HOST 'grep -E "filament|rfid|nfc" /home/lava/printer_data/config/printer.cfg | head -20'

echo ""
echo "4. Manual RFID read test (Channel 3)..."
#sshpass -p "$PASSWORD" ssh $SSH_OPTS root@$SSH_HOST 'curl -s "http://localhost:7125/printer/gcode/script?script=FILAMENT_DT_UPDATE%20CHANNEL=0"'
curl -s "http://$SSH_HOST:7125/printer/gcode/script?script=FILAMENT_DT_UPDATE%20CHANNEL=3"

echo ""
echo "5. Check recent RFID reads..."
sshpass -p "$PASSWORD" ssh $SSH_OPTS root@$SSH_HOST 'tail -100 /home/lava/printer_data/logs/klippy.log | grep -A 5 -B 5 "card data parsing"'

