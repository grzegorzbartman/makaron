#!/bin/bash
# Migration: Laptop gap default 0 -> 2
# v0.11.0 shipped AEROSPACE_GAP_SIZE_LAPTOP=0; the default is now 2 (a hairline
# between tiles). Only a conf still holding the old default is bumped.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Laptop gap default 0 -> 2"
MAKARON_CONF="${MAKARON_CONF:-$HOME/.config/makaron/makaron.conf}"

if [ -f "$MAKARON_CONF" ] && grep -qE '^AEROSPACE_GAP_SIZE_LAPTOP=0$' "$MAKARON_CONF"; then
    sed -i '' 's/^AEROSPACE_GAP_SIZE_LAPTOP=0$/AEROSPACE_GAP_SIZE_LAPTOP=2/' "$MAKARON_CONF"
    echo "  ✓ AEROSPACE_GAP_SIZE_LAPTOP set to 2"
else
    echo "  ✓ Nothing to change"
fi

echo "Migration completed successfully"
