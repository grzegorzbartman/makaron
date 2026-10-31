#!/bin/sh

source "$CONFIG_DIR/colors.sh"

# Wi-Fi link state from ifconfig (instant; system_profiler takes seconds)
WIFI_IF=$(networksetup -listallhardwareports 2>/dev/null | awk '/Wi-Fi|AirPort/{getline; print $2; exit}')

if [ -n "$WIFI_IF" ] && ifconfig "$WIFI_IF" 2>/dev/null | grep -q "status: active"; then
  ICON="󰖩"
else
  ICON="󰖪"
fi

sketchybar --set "$NAME" icon="$ICON" label="" \
  icon.color="${ICON_COLOR:-0xffc0caf5}"
