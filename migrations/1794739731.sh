#!/bin/bash
# Migration: SketchyBar at the bottom, Dock left, menu bar visible
# The autohidden menu bar slid out over the top bar and swallowed clicks. Full
# mode now keeps the macOS menu bar visible, pins the Dock to the left (always
# shown) and moves SketchyBar to the bottom edge. Applies the macOS side for
# users in full mode; makaron-update reloads the bar and the gaps afterwards.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: SketchyBar at the bottom, Dock left, menu bar visible"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
SNAPSHOT="$HOME/.local/state/makaron/defaults-snapshot/values"
UI_MODE_FILE="$HOME/.local/state/makaron/ui-mode"

# Keep the pre-Makaron Dock position for makaron-uninstall (write-once)
if [ -f "$SNAPSHOT" ] && ! grep -q '^com.apple.dock|orientation|' "$SNAPSHOT"; then
    val=$(defaults read com.apple.dock orientation 2>/dev/null) || val="__ABSENT__"
    type=$(defaults read-type com.apple.dock orientation 2>/dev/null | awk '{print $3}') || type=""
    printf 'com.apple.dock|orientation||%s|%s\n' "${type:-none}" "$val" >> "$SNAPSHOT"
fi

if [ "$(cat "$UI_MODE_FILE" 2>/dev/null)" != "full" ]; then
    echo "  ✓ UI not in full mode, nothing to apply"
    exit 0
fi

if [ "$(defaults read com.apple.dock orientation 2>/dev/null)" = "left" ] &&
    [ "$(defaults read com.apple.dock autohide 2>/dev/null)" = "0" ] &&
    [ "$(defaults read NSGlobalDomain _HIHideMenuBar 2>/dev/null)" = "0" ]; then
    echo "Already applied, skipping"
    exit 0
fi

# shellcheck source=/dev/null
source "$MAKARON_PATH/bin/makaron-ui-helpers"
defaults write com.apple.dock autohide -bool false
defaults write com.apple.dock orientation -string left
_restart_dock
echo "  ✓ Dock on the left, always visible"
if _set_menubar_autohide "Never"; then
    echo "  ✓ Menu bar always visible"
else
    echo "  ⚠️  Set System Settings > Menu Bar > Automatically hide and show the menu bar > Never"
fi

echo "Migration completed successfully"
