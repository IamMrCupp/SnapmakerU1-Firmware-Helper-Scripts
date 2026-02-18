#!/bin/bash

usage() {
    cat << EOF
Usage: $0 <ssh-host> <profile>

Compare RFID modules between printer and local overlay.

Arguments:
  ssh-host    Hostname or IP address of the printer (e.g., snapmaker-u1 or 192.168.1.100)
  profile     Profile name (currently unused, reserved for future use)

Environment Variables:
  PASSWORD    SSH password for root user (default: snapmaker)

Examples:
  # Compare RFID modules on your printer
  $0 snapmaker-u1 default

  # Use custom password
  PASSWORD=mypassword $0 192.168.1.100 default

What this script does:
  1. Lists RFID protocol modules installed on printer
  2. Shows RFID modules in local overlay (13-rfid-support)
  3. Checks filament_detect.py for OpenSpool imports
  4. Displays contents of filament_protocol_ndef.py
  5. Provides rebuild instructions

Requirements:
  - sshpass must be installed (brew install sshpass on macOS)
  - Network access to the printer
  - Root SSH access enabled on printer
  - Local overlay directory (optional for comparison)

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

echo "=== Comparing RFID modules ==="
echo "Host: $SSH_HOST"
echo ""
echo "On printer:"
sshpass -p "$PASSWORD" ssh $SSH_OPTS root@$SSH_HOST 'ls -1 /home/lava/klipper/klippy/extras/filament_protocol*.py'

echo ""
echo "In overlay 13-rfid-support:"
ls -1 overlays/firmware-extended/13-rfid-support/root/home/lava/klipper/klippy/extras/filament_protocol*.py 2>/dev/null || echo "No files in overlay"

echo ""
echo "=== Checking filament_detect.py for OpenSpool import ==="
sshpass -p "$PASSWORD" ssh $SSH_OPTS root@$SSH_HOST 'grep -n "openspool\|ndef" /home/lava/klipper/klippy/extras/filament_detect.py | head -10'

echo ""
echo "=== What does filament_protocol_ndef.py contain? ==="
sshpass -p "$PASSWORD" ssh $SSH_OPTS root@$SSH_HOST 'head -50 /home/lava/klipper/klippy/extras/filament_protocol_ndef.py'

echo ""
echo "=== Solution: Rebuild with current branch ==="
echo "Your filament-profiles-polymaker-panchroma branch should include RFID support."
echo "Run: make PROFILE=extended build"
