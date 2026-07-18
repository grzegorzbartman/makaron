#!/bin/bash
# Migration: Keep Dock auto-hidden in stopped UI mode
# Existing stopped installations should adopt the new Dock behavior on update.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Keep Dock auto-hidden in stopped UI mode"
UI_MODE_FILE="$HOME/.local/state/makaron/ui-mode"

if [ -f "$UI_MODE_FILE" ] && grep -q '^stop$' "$UI_MODE_FILE"; then
    defaults write com.apple.dock autohide -bool true
    killall Dock 2>/dev/null || true
    echo "  ✓ Dock auto-hide enabled"
else
    echo "  ✓ Not in stopped UI mode, nothing to do"
fi

echo "Migration completed successfully"
