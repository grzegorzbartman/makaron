#!/bin/bash
# Migration: Replace makaron-ui-start with makaron-ui-full/minimal
# Removes deprecated makaron-ui-start and informs about new commands

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Replace makaron-ui-start with makaron-ui-full/minimal"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

# Remove old makaron-ui-start if it exists
if [ -f "$MAKARON_PATH/bin/makaron-ui-start" ]; then
    rm -f "$MAKARON_PATH/bin/makaron-ui-start"
    echo "Removed deprecated makaron-ui-start"
fi

# Remove old macos-default theme wallpapers if they exist (now using system wallpaper)
rm -rf "$MAKARON_PATH/themes/macos-default-dark/backgrounds" 2>/dev/null || true
rm -rf "$MAKARON_PATH/themes/macos-default-light/backgrounds" 2>/dev/null || true

echo ""
echo "New UI commands available:"
echo "  makaron-ui-full    - Full UI (AeroSpace + SketchyBar + Borders)"
echo "  makaron-ui-minimal - Minimal UI (AeroSpace only, native macOS look)"
echo "  makaron-ui-stop    - Stop all UI components"
echo ""
echo "Migration completed successfully"

