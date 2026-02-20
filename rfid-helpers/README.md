# RFID/NFC Debugging Tools

Diagnostic utilities for debugging RFID/NFC filament detection features on the Snapmaker U1 printer.

## Overview

These scripts provide comprehensive diagnostics for RFID/NFC functionality on the Snapmaker U1. They help verify firmware modules, check configuration, monitor tag reads, and troubleshoot issues with filament detection.

## Requirements

- **Operating System**: Linux or macOS
- **Tools**:
  - `bash`
  - `sshpass` (install via: `brew install sshpass` on macOS)
- **Printer Access**:
  - SSH access to your Snapmaker U1 printer
  - Root user credentials (default password: `snapmaker`)
  - Network connectivity to the printer

**Getting Help**: All scripts support `-h`, `--help`, or running without arguments to display usage information.

## Scripts

### debug-rfid.sh

Debug general RFID/NFC functionality on your printer.

**What it checks:**
- RFID overlay presence in firmware
- Klipper logs for RFID activity
- Current filament detection configuration
- Manual RFID read test (Channel 3)
- Recent RFID card data parsing

**Usage:**
```bash
./debug-rfid.sh <printer-hostname> <profile>
```

**Examples:**
```bash
# Basic usage
./debug-rfid.sh snapmaker-u1 default

# With custom password
PASSWORD=mypassword ./debug-rfid.sh 192.168.1.100 default
```

### debug-ntag-reading.sh

Debug NTAG215 RFID tag reading with detailed diagnostics.

**What it does:**
- Verifies OpenSpool module installation
- Checks filament_detect.py imports
- Restarts Klipper to load new modules
- Checks Klipper loaded successfully
- Watches for RFID activity in logs
- Triggers manual read on channel 3
- Analyzes logs for tag detection patterns

**Usage:**
```bash
./debug-ntag-reading.sh <printer-hostname> <profile>
```

**Examples:**
```bash
# Basic usage
./debug-ntag-reading.sh snapmaker-u1 default

# With custom password
PASSWORD=mypassword ./debug-ntag-reading.sh 192.168.1.100 default
```

**Look for these patterns in output:**
- `ATQA: 0x44 0x00` = NTAG detected
- `NDEF RFID data:` = Tag being read
- `OpenSpool JSON payload:` = JSON parsed
- `wakeup err: -20` = Tag not responding (positioning issue)

### check-firmware-version.sh

Check current firmware version and extended features on your printer.

**What it checks:**
- Current firmware version installed on printer
- Extended firmware features (filament, openspool modules)
- Locally built firmware files
- Instructions for rebuilding with RFID support

**Usage:**
```bash
./check-firmware-version.sh <printer-hostname> <profile>
```

**Examples:**
```bash
# Basic usage
./check-firmware-version.sh snapmaker-u1 default

# With custom password
PASSWORD=mypassword ./check-firmware-version.sh 192.168.1.100 default
```

### compare-rfid-modules.sh

Compare RFID modules between your printer and local overlay.

**What it does:**
- Lists RFID protocol modules installed on printer
- Shows RFID modules in local overlay (13-rfid-support)
- Checks filament_detect.py for OpenSpool imports
- Displays contents of filament_protocol_ndef.py
- Provides rebuild instructions

**Usage:**
```bash
./compare-rfid-modules.sh <printer-hostname> <profile>
```

**Examples:**
```bash
# Basic usage
./compare-rfid-modules.sh snapmaker-u1 default

# With custom password
PASSWORD=mypassword ./compare-rfid-modules.sh 192.168.1.100 default
```

## Common Usage Patterns

### Quick Health Check

Run a quick check to verify RFID functionality:

```bash
./debug-rfid.sh snapmaker-u1 default
```

### Deep Dive Diagnostics

For detailed tag reading analysis:

```bash
./debug-ntag-reading.sh snapmaker-u1 default
```

### Firmware Validation

Check if extended firmware features are installed:

```bash
./check-firmware-version.sh snapmaker-u1 default
./compare-rfid-modules.sh snapmaker-u1 default
```

### Troubleshooting Workflow

1. **Check firmware version and modules:**
   ```bash
   ./check-firmware-version.sh snapmaker-u1 default
   ```

2. **Compare with expected modules:**
   ```bash
   ./compare-rfid-modules.sh snapmaker-u1 default
   ```

3. **Debug RFID functionality:**
   ```bash
   ./debug-rfid.sh snapmaker-u1 default
   ```

4. **Deep dive into tag reading (if needed):**
   ```bash
   ./debug-ntag-reading.sh snapmaker-u1 default
   ```

## Configuration

### Environment Variables

All scripts support the following environment variables:

- **`PASSWORD`** - SSH password for root user (default: `snapmaker`)

**Example:**
```bash
export PASSWORD=mypassword
./debug-rfid.sh snapmaker-u1 default
```

### SSH Options

Scripts use these SSH options for automated connections:
- `-o StrictHostKeyChecking=no` - Skips host key verification
- `-o UserKnownHostsFile=/dev/null` - Doesn't save host keys

## Troubleshooting

### "Command not found: sshpass"

Install sshpass:
```bash
# macOS
brew install sshpass

# Debian/Ubuntu
sudo apt-get install sshpass
```

### "Permission denied" or SSH failures

- Verify SSH access: `ssh root@snapmaker-u1`
- Check printer is on the network
- Ensure root SSH is enabled on the printer
- Verify password (default is `snapmaker`)

### "Module not found" errors

The RFID modules may not be installed in your firmware:
- Check if you're using extended firmware build
- Rebuild firmware with RFID support overlay
- Verify overlay files are in the correct location

### No RFID activity in logs

- Ensure filament with RFID tag is inserted
- Check tag positioning (remove and reinsert filament)
- Verify RFID reader hardware is functioning
- Try manual read trigger

## Technical Details

### SSH Connection

All scripts use:
```bash
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$SSH_HOST
```

### Default Paths on Printer

- **Klipper modules**: `/home/lava/klipper/klippy/extras/`
- **Klipper logs**: `/home/lava/printer_data/logs/klippy.log`
- **Printer config**: `/home/lava/printer_data/config/printer.cfg`
- **Firmware version**: `/home/lava/printer_data/config/snapmaker/.firmware_version`

### RFID Channels

The Snapmaker U1 has 4 RFID readers (channels 0-3):
- Scripts typically test channel 3
- Each channel corresponds to a filament slot

## Back to Main README

See [../README.md](../README.md) for repository overview and GUI binary patching tools.
