#!/bin/bash
# Migration: Ensure AeroSpace >= 0.21 for aerospace-swipe
# aerospace-swipe uses the AeroSpace v0.21 socket protocol. Existing users on
# older AeroSpace get a broken CLI fallback and swipes silently no-op. Upgrade
# AeroSpace, then rebuild/reload the swipe agent so it reconnects via socket.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Ensure AeroSpace >= 0.21"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

if [ -f "$MAKARON_PATH/install/helpers.sh" ]; then
    source "$MAKARON_PATH/install/helpers.sh"
fi

# Upgrades AeroSpace in place when older than 0.21
if [ -f "$MAKARON_PATH/install/desktop/aerospace.sh" ]; then
    source "$MAKARON_PATH/install/desktop/aerospace.sh"
fi

# Rebuild / reload aerospace-swipe so it reconnects to the new socket
if [ -f "$MAKARON_PATH/install/desktop/aerospace_swipe.sh" ]; then
    source "$MAKARON_PATH/install/desktop/aerospace_swipe.sh"
fi

echo "Migration completed successfully"
