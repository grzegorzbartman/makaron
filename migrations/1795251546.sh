#!/bin/bash
# Migration: Laptop bar height default -> auto
# v0.11-v0.16 shipped SKETCHYBAR_HEIGHT_LAPTOP=32, which is shorter than the
# notch strip at "More Space" scaling (37.5pt). auto follows the notch height.
# Only a conf still holding the old default is switched; a custom value is kept.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Laptop bar height default -> auto"
MAKARON_CONF="${MAKARON_CONF:-$HOME/.config/makaron/makaron.conf}"

if [ -f "$MAKARON_CONF" ] && grep -qE '^SKETCHYBAR_HEIGHT_LAPTOP=32$' "$MAKARON_CONF"; then
    sed -i '' 's/^SKETCHYBAR_HEIGHT_LAPTOP=32$/SKETCHYBAR_HEIGHT_LAPTOP=auto/' "$MAKARON_CONF"
    echo "  ✓ SKETCHYBAR_HEIGHT_LAPTOP set to auto"
else
    echo "  ✓ Nothing to change"
fi

echo "Migration completed successfully"
