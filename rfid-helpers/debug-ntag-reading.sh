#!/bin/bash

usage() {
    cat << 'USAGE_EOF'
Usage: $0 <ssh-host>

Debug NTAG215 RFID tag reading on Snapmaker U1 printer.

Arguments:
  ssh-host    Hostname or IP address of the printer (e.g., snapmaker-u1 or 192.168.1.100)

Environment Variables:
  PASSWORD    SSH password for root user (default: snapmaker)

Examples:
  $0 snapmaker-u1
  PASSWORD=mypassword $0 192.168.1.100

What this script does:
  1. Verifies OpenSpool module installation
  2. Checks filament_detect.py imports
  3. Restarts Klipper to load new modules
  4. Watches for RFID activity in logs
  5. Triggers manual read on channel 3
  6. Analyzes logs for tag detection patterns

Requirements:
  - sshpass installed (brew install sshpass on macOS)
  - Network access to printer
  - Root SSH access enabled
USAGE_EOF
    exit 1
}

SSH_HOST="$1"

if [ -z "$SSH_HOST" ]; then
    usage
fi

PASSWORD="${PASSWORD:-snapmaker}"
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"

if ! command -v sshpass &> /dev/null; then
    echo "Error: sshpass not found. Install with: brew install sshpass"
    exit 1
fi

ssh_exec() {
    sshpass -p "$PASSWORD" ssh $SSH_OPTS root@"$SSH_HOST" "$@"
}

echo "=== NTAG215 Reading Debug on $SSH_HOST ==="
echo ""

echo "1. Verify OpenSpool module is installed..."
ssh_exec 'ls -lh /home/lava/klipper/klippy/extras/filament_protocol_openspool.py 2>/dev/null && echo "✓ Module found" || echo "✗ Module NOT found"'

echo ""
echo "2. Check filament_detect.py imports..."
ssh_exec 'grep "import.*openspool\|import.*ndef" /home/lava/klipper/klippy/extras/filament_detect.py'

echo ""
echo "3. Restart Klipper to load new modules..."
ssh_exec 'systemctl restart klipper'
sleep 3

echo ""
echo "4. Check Klipper loaded successfully..."
ssh_exec 'systemctl status klipper | head -10'

echo ""
echo "5. Watch Klipper log for RFID activity (last 50 lines)..."
ssh_exec 'tail -50 /home/lava/printer_data/logs/klippy.log | grep -E "RFID|NTAG|NDEF|card|channel.*read|wakeup|ATQA"'

echo ""
echo "6. Trigger manual read on channel 3..."
curl -s "http://$SSH_HOST:7125/printer/gcode/script?script=FILAMENT_DT_UPDATE%20CHANNEL=3"
sleep 2

echo ""
echo "7. Check logs again for latest read attempt..."
ssh_exec 'tail -100 /home/lava/printer_data/logs/klippy.log | tail -30'

echo ""
echo "=== Analysis ==="
echo "Look for these patterns:"
echo "- 'ATQA: 0x44 0x00' = NTAG detected"
echo "- 'NDEF RFID data:' = Tag being read"
echo "- 'OpenSPool JSON payload:' = JSON parsed"
echo "- 'wakeup err: -20' = Tag not responding (positioning issue)"