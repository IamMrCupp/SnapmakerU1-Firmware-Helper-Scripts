# GUI Binary Patching Tools

Tools for analyzing and modifying the Snapmaker U1 GUI binary to add custom filament profiles.

## Overview

These scripts enable reverse-engineering and modification of the Snapmaker U1's GUI binary to add additional filament type profiles. The default firmware includes support for several Polymaker filaments, and these tools allow you to add more custom profiles.

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
  - `python3` (for Python scripts)
  - `xxd` (hex dump utility)
  - `readelf` (binary analysis)
  - `strings` (string extraction)
  - `file` (file type identification)

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

The default output location is `../output/gui-patched`.

### 3. Verify the Patch

After patching, verify the changes were applied correctly:

```bash
./verify-patches.sh ../output/gui-patched
```

### 4. Deploy the Patched Binary

Follow your device's firmware update procedure to deploy the modified GUI binary. **Always keep a backup of the original!**

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

## Examples

### Full Workflow Example

```bash
# 1. Analyze the binary
./analyze-gui.sh /path/to/original-gui
./check-space.sh /path/to/original-gui

# 2. Patch the binary (choose one method)
./replace-gui-strings.py /path/to/original-gui ../output/gui-patched

# 3. Verify the patch
./verify-patches.sh ../output/gui-patched

# 4. Deploy (example commands, not executed by these scripts)
# scp ../output/gui-patched root@snapmaker-u1:/tmp/
# ssh root@snapmaker-u1 'cp /usr/bin/gui /usr/bin/gui.bak'
# ssh root@snapmaker-u1 'cp /tmp/gui-patched /usr/bin/gui && chmod +x /usr/bin/gui'
```

## Troubleshooting

### Binary Won't Load After Patching

- Verify the patched binary size matches the original
- Check that all offsets are correct using `verify-patches.sh`
- Try the in-place replacement method instead of injection

### Profiles Don't Show Up in GUI

- Verify strings are at the correct offset using `xxd`
- Check pointer array is properly updated
- Ensure string length is 15 characters or less

### Crashes When Selecting New Profile

- Likely an address range validation issue
- Use the in-place replacement method (`replace-gui-strings.py`)
- Analyze crash logs to identify the issue

## Back to Main README

See [../README.md](../README.md) for repository overview and RFID debugging tools.
