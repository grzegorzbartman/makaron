#!/bin/sh
# Reload the bar when the macOS appearance (light/dark) changes, so
# colors.sh re-resolves the palette. Polled via update_freq; the first
# run only records the state (no reload loop at startup).

STATE_FILE="/tmp/sketchybar_$(id -u)_appearance"

CUR=$(defaults read -g AppleInterfaceStyle 2>/dev/null || echo Light)
PREV=$(cat "$STATE_FILE" 2>/dev/null)

if [ "$CUR" != "$PREV" ]; then
    echo "$CUR" > "$STATE_FILE"
    [ -n "$PREV" ] && sketchybar --reload
fi
