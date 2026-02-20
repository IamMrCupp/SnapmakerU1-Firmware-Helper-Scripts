# Snapmaker U1 Firmware Helper Scripts

A collection of scripts for analyzing and patching the Snapmaker U1 GUI binary to add custom filament profiles, plus RFID/NFC debugging utilities.

## Overview

This repository provides two main sets of tools:

1. **GUI Binary Patching** - Modify the Snapmaker U1 GUI binary to add custom filament profiles
2. **RFID/NFC Debugging** - Diagnose and troubleshoot RFID filament detection features

## ⚠️ Important Warnings

- **Use at your own risk!** Modifying firmware can potentially damage your device.
- **No warranty!** These scripts are provided as-is with no guarantees.
- **Backup your original firmware** before applying any patches.
- **Test thoroughly** after applying patches to ensure proper operation.
- Modifying firmware may void your warranty.

## Repository Organization

Scripts are organized by functional purpose:

### 📁 [`gui-changes/`](gui-changes/)

GUI binary analysis and patching tools for adding custom filament profiles.

**Key Scripts:**
- `patch-gui-binary.py` - Add new filament profiles (injection method)
- `replace-gui-strings.py` - Replace existing profiles in-place (recommended)
- `analyze-gui.sh` - Analyze binary structure
- `verify-patches.sh` - Verify patched binary

**📖 [Read the full GUI Patching Guide →](gui-changes/README.md)**

### 📁 [`rfid-helpers/`](rfid-helpers/)

RFID/NFC debugging and diagnostic utilities (requires SSH access to printer).

**Key Scripts:**
- `debug-rfid.sh` - General RFID/NFC diagnostics
- `debug-ntag-reading.sh` - Detailed NTAG215 tag reading analysis
- `check-firmware-version.sh` - Check firmware version and features
- `compare-rfid-modules.sh` - Compare RFID modules

**📖 [Read the full RFID Debugging Guide →](rfid-helpers/README.md)**

## Quick Start

### GUI Binary Patching

```bash
# 1. Analyze the binary
cd gui-changes
./analyze-gui.sh /path/to/gui

# 2. Patch (recommended method: in-place replacement)
./replace-gui-strings.py /path/to/gui ../output/gui-patched

# 3. Verify
./verify-patches.sh ../output/gui-patched
```

See the [GUI Changes README](gui-changes/README.md) for detailed instructions.

### RFID/NFC Debugging

```bash
# Quick health check
cd rfid-helpers
./debug-rfid.sh snapmaker-u1 default

# Detailed diagnostics
./debug-ntag-reading.sh snapmaker-u1 default

# With custom password
PASSWORD=mypassword ./debug-rfid.sh 192.168.1.100 default
```

See the [RFID Helpers README](rfid-helpers/README.md) for detailed instructions.

## Requirements

### System Requirements

- **Operating System**: Linux or macOS
- **Tools**: `bash`, `python3`, standard Unix utilities (`xxd`, `readelf`, `strings`, `file`)

### For GUI Binary Patching

No special requirements beyond system tools.

### For RFID/NFC Debugging

- `sshpass` (install via: `brew install sshpass` on macOS)
- SSH access to your Snapmaker U1 printer
- Root credentials (default password: `snapmaker`)

## Getting Help

All scripts support `-h`, `--help`, or running without arguments to display detailed usage information.

**Example:**
```bash
./gui-changes/patch-gui-binary.py --help
./rfid-helpers/debug-rfid.sh --help
```

## Repository Structure

```
.
├── gui-changes/                      # GUI binary patching tools
│   ├── README.md                     # Detailed GUI patching guide
│   ├── analyze-*.sh                  # Binary analysis scripts
│   ├── find-*.sh                     # Pattern finding scripts
│   ├── check-*.sh                    # Space verification scripts
│   ├── patch-gui-binary.py           # Injection patcher
│   ├── replace-gui-strings.py        # In-place patcher (recommended)
│   └── verify-patches.sh             # Patch verification
│
├── rfid-helpers/                     # RFID/NFC debugging utilities
│   ├── README.md                     # Detailed RFID debugging guide
│   ├── debug-rfid.sh                 # General RFID diagnostics
│   ├── debug-ntag-reading.sh         # NTAG215 tag analysis
│   ├── check-firmware-version.sh     # Firmware version check
│   └── compare-rfid-modules.sh       # Module comparison
│
└── output/                           # Auto-created output directory
    └── gui-patched                   # Default patched binary location
```

**Note:** The `output/` directory is created automatically and is excluded from git.

## Documentation

- **[GUI Changes Guide](gui-changes/README.md)** - Complete guide for GUI binary patching
- **[RFID Helpers Guide](rfid-helpers/README.md)** - Complete guide for RFID/NFC debugging

## Contributing

Contributions are welcome! If you discover new offsets, find bugs, or add support for additional features, please open a pull request.

**Areas for contribution:**
- Additional filament profile presets
- Support for other firmware versions
- Improved RFID diagnostic tools
- Documentation improvements

## License

This project is provided for educational and research purposes. Use responsibly and at your own risk.

## Disclaimer

This project is not affiliated with, endorsed by, or connected to Snapmaker or Polymaker. All trademarks belong to their respective owners.

## Support

For issues or questions:
- **General issues**: Open an issue on GitHub
- **GUI Patching**: See [gui-changes/README.md](gui-changes/README.md)
- **RFID Debugging**: See [rfid-helpers/README.md](rfid-helpers/README.md)

---

**Remember**: Always backup your original firmware before making any modifications!
