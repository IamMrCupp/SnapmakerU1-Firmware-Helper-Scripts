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

## Scripts

### Analysis Scripts

These scripts help you understand the binary structure and locate important data:

- **`analyze-gui.sh`** - Analyzes the GUI binary to find filament strings and architecture info
- **`check-space.sh`** - Verifies available space for new strings and pointers
- **`find-array-usage.sh`** - Locates array patterns in the binary
- **`find-empty-space.sh`** - Finds unused/empty space in the binary
- **`find-loop-counter.sh`** - Searches for loop counter patterns
- **`find-pointers.sh`** - Locates pointer arrays to filament strings
- **`find-trans-type-function.sh`** - Finds translation type functions

### Patching Scripts

- **`patch-gui-binary.py`** - Python script that patches the binary to add new filament profiles
- **`patch-gui.sh`** - Shell script wrapper for analyzing and preparing patches

## Usage

### 1. Analyze the Binary

First, run the analysis scripts to understand the binary structure:

```bash
./analyze-gui.sh <path-to-gui-binary>
./check-space.sh <path-to-gui-binary>
./find-pointers.sh <path-to-gui-binary>
```

### 2. Patch the Binary

Use the Python patcher to add new filament profiles:

```bash
./patch-gui-binary.py <path-to-gui-binary> [output-file]
```

The default output location is `output/gui-patched`.

### 3. Deploy the Patched Binary

Follow your device's firmware update procedure to deploy the modified GUI binary. **Always keep a backup of the original!**

## Default Filament Profiles Added

The patcher adds these Polymaker filament profiles:

1. **Panchroma PLA**
2. **Panchroma Matte**
3. **Panchroma Silk**
4. **PolyLite PLA**
5. **PolyMax PLA**
6. **PolyMax PETG**

## Customization

To modify which profiles are added, edit the `NEW_PROFILES` list in [patch-gui-binary.py](patch-gui-binary.py):

```python
NEW_PROFILES = [
    "Your Profile 1",   # Max 15 characters
    "Your Profile 2",
    # Add more profiles here
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
├── analyze-gui.sh                    # Analyze binary structure
├── check-space.sh                    # Check available space
├── find-array-usage.sh               # Find array patterns
├── find-empty-space.sh               # Locate empty space
├── find-loop-counter.sh              # Find loop counters
├── find-pointers.sh                  # Find pointer arrays
├── find-trans-type-function.sh       # Find translation functions
├── patch-gui-binary.py               # Main Python patcher
├── patch-gui.sh                      # Shell patcher wrapper
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
