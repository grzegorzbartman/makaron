#!/bin/bash
# Migration: Remove aerospace-swipe
# Makaron no longer installs or updates aerospace-swipe (dropped in v0.12.0).
# Stops its LaunchAgent, removes the app + config Makaron installed, and drops
# AEROSPACE_SWIPE_* from makaron.conf.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Remove aerospace-swipe"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
MAKARON_CONF="$HOME/.config/makaron/makaron.conf"
SWIPE_PLIST="$HOME/Library/LaunchAgents/com.acsandmann.swipe.plist"
SWIPE_DIR="$HOME/.local/share/aerospace-swipe"
SWIPE_CONF_DIR="$HOME/.config/aerospace-swipe"

if [ -f "$SWIPE_PLIST" ] || [ -d "$SWIPE_DIR" ] || [ -d "$SWIPE_CONF_DIR" ]; then
    launchctl unload "$SWIPE_PLIST" 2>/dev/null || true
    rm -f "$SWIPE_PLIST"
    rm -rf "$SWIPE_DIR" "$SWIPE_CONF_DIR"
    echo "  ✓ Removed aerospace-swipe (reinstall manually: https://github.com/acsandmann/aerospace-swipe)"
else
    echo "  ✓ aerospace-swipe not installed"
fi

if [ -f "$MAKARON_CONF" ] && grep -q '^AEROSPACE_SWIPE_' "$MAKARON_CONF"; then
    sed -i '' '/^AEROSPACE_SWIPE_/d' "$MAKARON_CONF"
    [ -f "$MAKARON_PATH/install/makaron-conf.sh" ] && source "$MAKARON_PATH/install/makaron-conf.sh"
    echo "  ✓ Removed AEROSPACE_SWIPE_* from makaron.conf"
fi

echo "Migration completed successfully"
