#!/bin/bash

# Generate macOS iconset from a master 1024x1024 image
# Usage: ./generate-iconset.sh <source-image.png>

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <source-image.png>"
    echo "  source-image.png should be 1024x1024 pixels"
    exit 1
fi

SOURCE="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ICONSET_DIR="$PROJECT_DIR/Posturr.iconset"

if [ ! -f "$SOURCE" ]; then
    echo "Error: Source image not found: $SOURCE"
    exit 1
fi

echo "Creating iconset from: $SOURCE"

# Remove existing iconset
rm -rf "$ICONSET_DIR"
mkdir -p "$ICONSET_DIR"

# Generate all required sizes
# Using sips (built into macOS) for resizing
echo "Generating icon sizes..."

sips -z 16 16     "$SOURCE" --out "$ICONSET_DIR/icon_16x16.png" > /dev/null
sips -z 32 32     "$SOURCE" --out "$ICONSET_DIR/icon_16x16@2x.png" > /dev/null
sips -z 32 32     "$SOURCE" --out "$ICONSET_DIR/icon_32x32.png" > /dev/null
sips -z 64 64     "$SOURCE" --out "$ICONSET_DIR/icon_32x32@2x.png" > /dev/null
sips -z 128 128   "$SOURCE" --out "$ICONSET_DIR/icon_128x128.png" > /dev/null
sips -z 256 256   "$SOURCE" --out "$ICONSET_DIR/icon_128x128@2x.png" > /dev/null
sips -z 256 256   "$SOURCE" --out "$ICONSET_DIR/icon_256x256.png" > /dev/null
sips -z 512 512   "$SOURCE" --out "$ICONSET_DIR/icon_256x256@2x.png" > /dev/null
sips -z 512 512   "$SOURCE" --out "$ICONSET_DIR/icon_512x512.png" > /dev/null
sips -z 1024 1024 "$SOURCE" --out "$ICONSET_DIR/icon_512x512@2x.png" > /dev/null

echo "Generated iconset at: $ICONSET_DIR"

# Convert to icns
echo "Converting to icns..."
iconutil -c icns -o "$PROJECT_DIR/AppIcon.icns" "$ICONSET_DIR"

echo "Created: $PROJECT_DIR/AppIcon.icns"

# Cleanup iconset folder (optional - keep for reference)
# rm -rf "$ICONSET_DIR"

echo ""
echo "Icon generation complete!"
echo "Run ./build.sh to include the icon in the app bundle."
