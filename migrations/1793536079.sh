#!/bin/bash
# Migration: Laptop gap default -> 6
# v0.11-v0.14 shipped AEROSPACE_GAP_SIZE_LAPTOP=0 and v0.15 shipped 2; both
# read as "glued" tiles on a 13" screen. Only a conf still holding one of
# those old defaults is bumped to 6; a custom value is kept.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Laptop gap default -> 6"
MAKARON_CONF="${MAKARON_CONF:-$HOME/.config/makaron/makaron.conf}"

if [ -f "$MAKARON_CONF" ] && grep -qE '^AEROSPACE_GAP_SIZE_LAPTOP=[02]$' "$MAKARON_CONF"; then
    sed -i '' 's/^AEROSPACE_GAP_SIZE_LAPTOP=[02]$/AEROSPACE_GAP_SIZE_LAPTOP=6/' "$MAKARON_CONF"
    echo "  ✓ AEROSPACE_GAP_SIZE_LAPTOP set to 6"
else
    echo "  ✓ Nothing to change"
fi

echo "Migration completed successfully"
