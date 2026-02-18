# Snapmaker U1 Firmware Helper Scripts

A collection of scripts for analyzing and patching the Snapmaker U1 GUI binary to add custom filament profiles.

## Overview

These scripts allow you to reverse-engineer and modify the Snapmaker U1's GUI binary to add additional filament type profiles. The default firmware includes support for several Polymaker filaments, and these tools enable you to add more custom profiles.

## ⚠️ Important Warnings

- **Use at your own risk!** Modifying firmware can potentially damage your device.
- **No warranty!** These scripts are provided as-is with no guarantees.
- **Backup your original firmware** before applying any patches.
- **Test thoroughly** after applying patches to ensure proper operation.
- Modifying firmware may void your warranty.

## Requirements

- **Operating System**: Linux or macOS
- **Tools**:
  - `bash` (for shell scripts)
  - `python3` (for patch-gui-binary.py)
  - `xxd` (hex dump utility)
  - `readelf` (binary analysis)
  - `strings` (string extraction)
  - `file` (file type identification)
  - `sshpass` (for SSH automation, install via: `brew install sshpass` on macOS)

**Getting Help**: All scripts support `-h`, `--help`, or running without arguments to display usage information.

## Scripts

### Analysis Scripts

These scripts help you understand the binary structure and locate important data:

- **`analyze-gui.sh`** - Analyzes the GUI binary to find filament strings and architecture info
- **`analyze-crash.sh`** - Analyzes address ranges to diagnose crashes and validate memory regions
- **`check-space.sh`** - Verifies available space for new strings and pointers
- **`check-generic-space.sh`** - Checks space after generic filaments for potential use
- **`find-array-usage.sh`** - Locates array patterns in the binary
- **`find-empty-space.sh`** - Finds unused/empty space in the binary
- **`find-loop-counter.sh`** - Searches for loop counter patterns
- **`find-pointers.sh`** - Locates pointer arrays to filament strings
- **`find-space-in-region.sh`** - Searches for long zero runs in specific memory regions
- **`find-trans-type-function.sh`** - Finds translation type functions

### Patching Scripts

- **`patch-gui-binary.py`** - Adds new filament profiles by injecting strings into empty space
- **`replace-gui-strings.py`** - Replaces existing Polymaker strings in-place with preferred profiles
- **`patch-gui.sh`** - Shell script wrapper for analyzing and preparing patches

### Verification Scripts

- **`verify-patches.sh`** - Verifies patched binary structure, strings, and pointers are correct

### Debugging Scripts

- **`debug-rfid.sh`** - Debug RFID/NFC functionality on Snapmaker U1 printer (requires SSH access)

## Usage

### 1. Analyze the Binary

First, run the analysis scripts to understand the binary structure:

```bash
./analyze-gui.sh <path-to-gui-binary>
./check-space.sh <path-to-gui-binary>
./find-pointers.sh <path-to-gui-binary>
```

### 2. Patch the Binary

You have two patching options:

**Option A: Add new profiles (injects strings into empty space)**
```bash
./patch-gui-binary.py <path-to-gui-binary> [output-file]
```

**Option B: Replace existing profiles in-place**
```bash
./replace-gui-strings.py <path-to-gui-binary> [output-file]
```

The default output location is `output/gui-patched`.

### 3. Verify the Patch

After patching, verify the changes were applied correctly:

```bash
./verify-patches.sh output/gui-patched
```

### 3. Deploy the Patched Binary

Follow your device's firmware update procedure to deploy the modified GUI binary. **Always keep a backup of the original!**
## Debugging RFID/NFC

To debug RFID/NFC functionality on your Snapmaker U1:

```bash
./debug-rfid.sh <printer-hostname> <profile>
```

Example:
```bash
./debug-rfid.sh snapmaker-u1 default
# or with custom password
PASSWORD=mypassword ./debug-rfid.sh 192.168.1.100 default
```

This script requires:
- SSH access to your printer (root user)
- `sshpass` installed (`brew install sshpass` on macOS)
- Network connectivity to the printer
## Patching Methods

### Method 1: Add New Profiles (patch-gui-binary.py)

This method injects 6 new filament profiles into unused memory space:

1. **Panchroma PLA**
2. **Panchroma Matte**
3. **Panchroma Silk**
4. **PolyLite PLA**
5. **PolyMax PLA**
6. **PolyMax PETG**

**Pros**: Keeps all original profiles  
**Cons**: May have address range validation issues on some firmware versions

### Method 2: Replace Existing Profiles (replace-gui-strings.py)

This method replaces 5 existing Polymaker profiles in-place:

- Polylite PLA → **Panchroma PLA**
- PolySonic PLA → **Panchroma Matte**
- PolyTerra PLA → **Panchroma Silk**
- Polylite ABS → **PolyMax PLA**
- Polylite PETG → **PolyMax PETG**

**Pros**: More stable, no address range issues  
**Cons**: Replaces existing profiles (though all 12 profiles still work in Klipper/web interface)

## Customization

### Adding New Profiles

To modify which profiles are added, edit the `NEW_PROFILES` list in [patch-gui-binary.py](patch-gui-binary.py):

```python
NEW_PROFILES = [
    "Your Profile 1",   # Max 15 characters
    "Your Profile 2",
    # Add more profiles here
]
```

### Replacing Existing Profiles

To change which profiles are replaced in-place, edit the `REPLACEMENTS` list in [replace-gui-strings.py](replace-gui-strings.py):

```python
REPLACEMENTS = [
    (0x31b7f0, "Polylite PLA",   "Your New Profile"),
    # Add more replacements here
]
```

**Note**: Each profile name must be 15 characters or less (plus null terminator = 16 bytes total).

## Technical Details

### Binary Offsets (ARM64)

- **New Strings Offset**: `0x1b7e80` - Location in `.rodata` section for new strings
- **Pointer Array Offset**: `0x615b50` - Location to add new pointers
- **String Size**: 16 bytes each (15 chars + null terminator)

### How It Works

1. The patcher writes new filament profile strings to unused space in the `.rodata` section
2. It then adds pointers to these strings in the filament type array
3. The GUI binary reads this array at runtime to populate the filament dropdown

## Repository Structure

```
.
├── analyze-crash.sh                  # Analyze address ranges for crashes
├── analyze-gui.sh                    # Analyze binary structure
├── check-generic-space.sh            # Check space after generic filaments
├── check-space.sh                    # Check available space
├── debug-rfid.sh                     # Debug RFID/NFC functionality (SSH)
├── find-array-usage.sh               # Find array patterns
├── find-empty-space.sh               # Locate empty space
├── find-loop-counter.sh              # Find loop counters
├── find-pointers.sh                  # Find pointer arrays
├── find-space-in-region.sh           # Find zero runs in memory regions
├── find-trans-type-function.sh       # Find translation functions
├── patch-gui-binary.py               # Add new profiles (injection method)
├── replace-gui-strings.py            # Replace existing profiles (in-place method)
├── patch-gui.sh                      # Shell patcher wrapper
├── verify-patches.sh                 # Verify patched binary integrity
└── output/                           # Output directory for patched files
    └── gui-patched                   # Default output filename
```

## Contributing

Contributions are welcome! If you discover new offsets, find bugs, or add support for additional features, please open a pull request.

## License

This project is provided for educational and research purposes. Use responsibly and at your own risk.

## Disclaimer

This project is not affiliated with, endorsed by, or connected to Snapmaker or Polymaker. All trademarks belong to their respective owners.

## Support

For issues or questions, please open an issue on GitHub.

---

**Remember**: Always backup your original firmware before making any modifications!
