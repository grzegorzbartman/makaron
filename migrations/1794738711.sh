#!/bin/bash
# Migration: One flat SketchyBar
# The floating desktop bar is gone: every screen gets the flat edge-to-edge
# bar, sized to the notch strip on notched displays. A conf still holding the
# old desktop default SKETCHYBAR_HEIGHT=40 moves to 32; SKETCHYBAR_HEIGHT_LAPTOP
# is no longer used and is removed. A custom SKETCHYBAR_HEIGHT is kept.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: One flat SketchyBar"
MAKARON_CONF="${MAKARON_CONF:-$HOME/.config/makaron/makaron.conf}"

if [ ! -f "$MAKARON_CONF" ]; then
    echo "  ✓ Nothing to change"
    exit 0
fi

if grep -q '^SKETCHYBAR_HEIGHT=40$' "$MAKARON_CONF"; then
    sed -i '' 's/^SKETCHYBAR_HEIGHT=40$/SKETCHYBAR_HEIGHT=32/' "$MAKARON_CONF"
    echo "  ✓ SKETCHYBAR_HEIGHT set to 32"
fi
if grep -q '^SKETCHYBAR_HEIGHT_LAPTOP=' "$MAKARON_CONF"; then
    sed -i '' '/^SKETCHYBAR_HEIGHT_LAPTOP=/d' "$MAKARON_CONF"
    echo "  ✓ SKETCHYBAR_HEIGHT_LAPTOP removed"
fi

echo "Migration completed successfully"
