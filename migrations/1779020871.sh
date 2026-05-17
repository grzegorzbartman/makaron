#!/bin/bash
# Migration: Default SKETCHYBAR_HIDE_EMPTY_WORKSPACES to true
#
# The previous migration added the flag with the cautious default `false` so
# existing users wouldn't see any visual change. The new project default is
# `true` (empty workspaces hidden, focused workspace always drawn). This
# migration flips the value to `true` for users who still have it at the
# old default. If you've already set it to anything else, you're left alone.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Default SKETCHYBAR_HIDE_EMPTY_WORKSPACES to true"

MAKARON_CONF="${MAKARON_CONF:-$HOME/.config/makaron/makaron.conf}"

if [ ! -f "$MAKARON_CONF" ]; then
    echo "  $MAKARON_CONF not present, skipping"
    exit 0
fi

if grep -q '^SKETCHYBAR_HIDE_EMPTY_WORKSPACES=true' "$MAKARON_CONF" 2>/dev/null; then
    echo "  Already true, leaving as-is"
elif grep -q '^SKETCHYBAR_HIDE_EMPTY_WORKSPACES=false' "$MAKARON_CONF" 2>/dev/null; then
    sed -i '' 's/^SKETCHYBAR_HIDE_EMPTY_WORKSPACES=false/SKETCHYBAR_HIDE_EMPTY_WORKSPACES=true/' "$MAKARON_CONF"
    echo "  Flipped SKETCHYBAR_HIDE_EMPTY_WORKSPACES from false to true"
elif grep -q '^SKETCHYBAR_HIDE_EMPTY_WORKSPACES=' "$MAKARON_CONF" 2>/dev/null; then
    echo "  Custom value found, leaving as-is"
else
    echo "" >> "$MAKARON_CONF"
    echo "# SketchyBar: hide empty AeroSpace workspaces from the bar" >> "$MAKARON_CONF"
    echo "# The focused workspace is always drawn, even if it's empty." >> "$MAKARON_CONF"
    echo "SKETCHYBAR_HIDE_EMPTY_WORKSPACES=true" >> "$MAKARON_CONF"
    echo "  Added SKETCHYBAR_HIDE_EMPTY_WORKSPACES=true"
fi

if command -v sketchybar >/dev/null 2>&1 && pgrep -x sketchybar >/dev/null 2>&1; then
    if sketchybar --reload 2>/dev/null; then
        echo "  SketchyBar reloaded"
    else
        echo "  Warning: sketchybar --reload failed (will pick up on next launch)"
    fi
fi

echo "Migration completed successfully"
