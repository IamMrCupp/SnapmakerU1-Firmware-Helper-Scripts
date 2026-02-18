#!/bin/bash

usage() {
    cat << EOF
Usage: $0 <ssh-host> <profile>

Check firmware version and extended features on Snapmaker U1 printer.

Arguments:
  ssh-host    Hostname or IP address of the printer (e.g., snapmaker-u1 or 192.168.1.100)
  profile     Profile name (currently unused, reserved for future use)

Environment Variables:
  PASSWORD    SSH password for root user (default: snapmaker)

Examples:
  # Check firmware version
  $0 snapmaker-u1 default

  # Use custom password and IP address
  PASSWORD=mypassword $0 192.168.1.100 default

What this script checks:
  1. Current firmware version installed on printer
  2. Extended firmware features (filament, openspool modules)
  3. Locally built firmware files
  4. Instructions for rebuilding with RFID support

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

echo "=== Checking current firmware on printer ==="
echo "Host: $SSH_HOST"
echo ""
sshpass -p "$PASSWORD" ssh $SSH_OPTS root@$SSH_HOST 'cat /home/lava/printer_data/config/snapmaker/.firmware_version 2>/dev/null || echo "Version file not found"'

echo ""
echo "=== Checking if extended firmware features are present ==="
sshpass -p "$PASSWORD" ssh $SSH_OPTS root@$SSH_HOST 'ls -la /home/lava/klipper/klippy/extras/ | grep -E "filament|openspool"'

echo ""
echo "=== What firmware do you have built locally? ==="
ls -lh firmware/*.bin 2>/dev/null || echo "No firmware built yet"

echo ""
echo "=== To rebuild with RFID support ==="
echo "Run: make PROFILE=extended build"
echo "This will include overlay 13-rfid-support"
