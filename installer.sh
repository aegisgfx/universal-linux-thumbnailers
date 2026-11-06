#!/bin/bash

# Universal Linux Thumbnailers Installer
# Installs thumbnailer files for non-deb (snap, flatpak) applications

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print banner
echo -e "${GREEN}=== Universal Linux Thumbnailers Installer ===${NC}"
echo "This installer adds thumbnail support for snap and flatpak applications."
echo ""

# Check for ImageMagick
if ! command -v convert &> /dev/null; then
    echo -e "${YELLOW}Warning: ImageMagick not found. Some thumbnailers require ImageMagick.${NC}"
    echo "Install ImageMagick with: sudo apt install imagemagick"
    echo ""
fi

# Install thumbnailers to user's thumbnailer directory
INSTALL_DIR="$HOME/.local/share/thumbnailers"
mkdir -p "$INSTALL_DIR"

# Copy all .thumbnailer files from all application directories
success_count=0
error_count=0

for app_dir in blender-snap gimp-flatpak krita-flatpak photoshop-psd blender-flatpak; do
    if [ -d "$app_dir" ]; then
        echo -e "${YELLOW}Processing $app_dir...${NC}"
        for thumbnailer in "$app_dir"/*.thumbnailer; do
            if [ -f "$thumbnailer" ]; then
                filename=$(basename "$thumbnailer")
                dest="$INSTALL_DIR/$filename"
                if [ ! -f "$dest" ] || [ "$thumbnailer" -nt "$dest" ]; then
                    cp "$thumbnailer" "$dest"
                    echo -e "  ${GREEN}✓${NC} Installed $filename"
                    success_count=$((success_count + 1))
                else
                    echo -e "  ${YELLOW}⚠${NC} $filename already exists and is up to date"
                fi
            fi
        done
    fi
done

# Refresh thumbnails
echo ""
echo -e "${YELLOW}Refreshing thumbnails...${NC}"
if command -v rm &> /dev/null && command -v nemo &> /dev/null; then
    rm -rf "$HOME/.cache/thumbnails/*" 2>/dev/null && nemo -q >/dev/null 2>&1
    echo -e "${GREEN}✓${NC} Thumbnails refreshed"
elif command -v thunar &> /dev/null; then
    rm -rf "$HOME/.cache/thumbnails/*" 2>/dev/null && thunar --no-ask -q >/dev/null 2>&1
    echo -e "${GREEN}✓${NC} Thumbnails refreshed"
else
    echo -e "${YELLOW}⚠${NC} File manager not found, cannot refresh thumbnails automatically"
    echo "You can refresh manually with: rm -rf ~/.cache/thumbnails/* && nautilus -q"
fi

# Print summary
echo ""
echo -e "${GREEN}=== Installation Summary ===${NC}"
echo "Successfully installed $success_count thumbnailer(s)"
echo -e "Errors: $error_count"
echo ""
echo "Your thumbnailers are now active. You may need to restart your file manager."
echo ""
echo "For more information, see the README.md file in this project."
echo ""
echo -e "${GREEN}=== Installer Complete ===${NC}"