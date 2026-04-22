#!/bin/sh

# Load theme colors
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
THEME_DIR="$MAKARON_PATH/current-theme"
if [ -f "$THEME_DIR/sketchybar.colors" ]; then
  source "$THEME_DIR/sketchybar.colors"
fi

# Get WiFi SSID using system_profiler (works on macOS 15+)
SSID=$(system_profiler SPAirPortDataType 2>/dev/null | awk '/Current Network Information:/{getline; if ($0 ~ /^            [^ ]/) {gsub(/^ +| *:$/, ""); print; exit}}')

if [ -z "$SSID" ]; then
  ICON="󰖪"
else
  ICON="󰖩"
fi

sketchybar --set "$NAME" icon="$ICON" label="" \
  icon.color="${ICON_COLOR:-0xffc0caf5}"

