#!/bin/bash
# Migration: Clean up makaron.conf leftovers
# Removes variables of removed features and regenerates the file from the
# template (structure + comments). User values are preserved.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Clean up makaron.conf leftovers"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
MAKARON_CONF="$HOME/.config/makaron/makaron.conf"

if [ -f "$MAKARON_CONF" ]; then
    sed -i '' \
        -e '/^MAKARONBAR_/d' \
        -e '/^MAKARON_TIMER_/d' \
        -e '/^MAKARON_NOTES_ENABLED=/d' \
        -e '/^SKETCHYBAR_NOTES_ENABLED=/d' \
        -e '/^MAKARON_THEME=/d' \
        -e '/^THEME_SET_WALLPAPER=/d' \
        -e '/^THEME_SET_MACOS_APPEARANCE=/d' \
        -e '/^BORDERS_ENABLED=/d' \
        -e '/^BORDER_WIDTH=/d' \
        "$MAKARON_CONF"
    echo "  ✓ Removed variables of removed features"
fi

if [ -f "$MAKARON_PATH/install/makaron-conf.sh" ]; then
    source "$MAKARON_PATH/install/makaron-conf.sh"
    echo "  ✓ makaron.conf regenerated from template"
fi

echo "Migration completed successfully"
