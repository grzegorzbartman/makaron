#!/bin/sh

source "$CONFIG_DIR/colors.sh"

# Get WiFi SSID using system_profiler (works on macOS 15+)
SSID=$(system_profiler SPAirPortDataType 2>/dev/null | awk '/Current Network Information:/{getline; if ($0 ~ /^            [^ ]/) {gsub(/^ +| *:$/, ""); print; exit}}')

if [ -z "$SSID" ]; then
  ICON="󰖪"
else
  ICON="󰖩"
fi

sketchybar --set "$NAME" icon="$ICON" label="" \
  icon.color="${ICON_COLOR:-0xffc0caf5}"

