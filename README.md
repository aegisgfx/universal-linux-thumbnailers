# Universal Linux Thumbnailers

Purpose: Add thumbnail support for non-deb installs of Blender, GIMP, Krita, and PSD files on Linux.

Specifically snap Blender, flatpak GIMP and Krita, since these installs do not seem to generate thumbnails natively on Ubuntu/Mint/Debian.

### Supported Applications and Their Thumbnailers

| Application | Format | Package Manager | Thumbnailer File | Mechanism |
|-------------|--------|-----------------|------------------|-----------|
| Blender (.blend) | `.blend` files | Snap / Flatpak | `blender.thumbnailer` | Extracts embedded PNG thumbnail from the `.blend` binary |
| GIMP (.xcf) | `.xcf` files | Flatpak | `xcf.thumbnailer` | Unzips XCF; ImageMagick converts layers to PNG |
| Krita (.kra) | `.kra` files | Flatpak | `kra.thumbnailer` | Unzips `preview.png` from `.kra` archive |
| Photoshop (.psd) | `.psd` files | Flatpak (GIMP too) | `psd.thumbnailer` | ImageMagick extracts first layer and resizes |

### Requirements

* ImageMagick (`convert`) for `.xcf` and `.psd` thumbnailers
* Standard Linux filesystem layout with thumbnailers installed at:
  * `~/.local/share/thumbnailers/` (user) — used by default
  * `/usr/share/thumbnailers/` or `/usr/local/share/thumbnailers/` (system-wide)
* GNOME Files (Nautilus), Caja, Dolphin, or any file manager that respects the thumbnailer registry

### Quick Install Instructions

Install all four thumbnailers into your user thumbnailers directory:

```bash
sh installer.sh
```

Or manually:

```bash
mkdir -p ~/.local/share/thumbnailers
cp blender-snap/blender.thumbnailer        ~/.local/share/thumbnailers/
cp gimp-flatpak/xcf.thumbnailer             ~/.local/share/thumbnailers/
cp krita-flatpak/kra.thumbnailer           ~/.local/share/thumbnailers/
cp photoshop-psd/psd.thumbnailer           ~/.local/share/thumbnailers/
```

### Refreshing Thumbnails

To force regeneration of all cached thumbnails:

```bash
rm -rf ~/.cache/thumbnails/* && nautilus -q
```

### Improving or Adding a Thumbnailer

To add a new application, create a subdirectory under this repo containing its `.thumbnailer` file and include it in the installer script. Example structure:

```
universal-linux-thumbnailers/
├── blender-snap/       # ← example already exists
├── blender-flatpak/    # ← new (you suggested)
├── gimp-flatpak/
├── krita-flatpak/
├── photoshop-psd/
└── installer.sh
```

A blank `.thumbnailer` file needs only three lines:

```ini
[Thumbnailer Entry]
TryExec=<path>
Exec=<command> %i %o
MimeType=application/x-<app>;
```

### Additional Notes

* **Blender**: The `blender-thumbnailer` binary is shipped inside both the snap and flatpak of Blender (at known paths). The embedded PNG thumbnail lives at the start of every `.blend` file. This approach works without launching Blender at all.
* **XCF files**: The flattened XCF renders reasonably well with newer ImageMagick 7 installs. ImageMagick 6 may work but XCF is no longer officially supported; it was added as an experimental delegate. Some older GIMP-version-2.10 XCF files may render incorrectly.
* **Krita**: Uses a pre-existing `preview.png` inside the `.kra` zip. Simple and reliable.
* **Photoshop (.psd)**: Extracts the first layer (`[0]`) and resizes. Note that this only renders the first image layer if present; text layers are ignored.

### Troubleshooting

1. **Thumbnails still don't show** — restart the file manager or log out and back in:
   ```
   killall nautilus || true
   nautilus &
   ```
2. **Blender / Krita thumbnails are missing** after installing via `installer.sh` — make sure the executable exists in the expected location. Run `ls -la $(which convert)` to verify.
3. **Conflicting thumbnailer errors** — look for duplicate `.thumbnailer` entries in `~/.local/share/thumbnailers/` and remove stale ones.

#### Report Bugs

Report bugs to [https://github.com/<your-user>/universal-linux-thumbnailers/issues](https://github.com/<your-user>/universal-linux-thumbnailers/issues).

Include the OS version, file manager used, and whether you installed via snap or flatpak.