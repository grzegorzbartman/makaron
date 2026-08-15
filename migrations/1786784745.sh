#!/bin/bash
# Migration: Enable Themes v2 window layout
# Activates the bordered layout for users migrated by the first Themes v2 release.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Enable Themes v2 window layout"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

if [ -f "$MAKARON_PATH/install/makaron-conf.sh" ]; then
    source "$MAKARON_PATH/install/makaron-conf.sh"
fi

if grep -qx 'BORDERS_ENABLED=false' "$MAKARON_CONF" &&
    grep -qx 'AEROSPACE_GAP_SIZE=0' "$MAKARON_CONF"; then
    sed -i '' 's/^BORDERS_ENABLED=false$/BORDERS_ENABLED=true/' "$MAKARON_CONF"
    sed -i '' 's/^AEROSPACE_GAP_SIZE=0$/AEROSPACE_GAP_SIZE=12/' "$MAKARON_CONF"
fi

echo "Migration completed successfully"
