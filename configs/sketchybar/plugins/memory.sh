#!/bin/sh
# Memory alert for SketchyBar: hidden below MEMORY_ALERT_THRESHOLD, shown as
# a warning pill when memory pressure is high. Uses makaron-memory-stats
# (Mach host_statistics64, matches Activity Monitor).

MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
source "$CONFIG_DIR/colors.sh"

MEMORY_ALERT_THRESHOLD=80
[ -f "$HOME/.config/makaron/makaron.conf" ] && . "$HOME/.config/makaron/makaron.conf"
case "$MEMORY_ALERT_THRESHOLD" in (*[!0-9]*|"") MEMORY_ALERT_THRESHOLD=80 ;; esac

# Output format: "13.2/32 GB"
STATS=$("$MAKARON_PATH/bin/makaron-memory-stats" 2>/dev/null)
PCT=$(echo "$STATS" | awk -F'[/ ]' 'NF>=2 && $2>0 {printf "%.0f", $1*100/$2}')
[ -z "$PCT" ] && exit 0

if [ "$PCT" -ge "$MEMORY_ALERT_THRESHOLD" ]; then
  sketchybar --set "$NAME" drawing=on label="${PCT}%" \
    background.color="${ALERT_BACKGROUND_COLOR:-0x26ff3b30}" \
    icon.color="${ALERT_COLOR:-0xffff3b30}" \
    label.color="${ALERT_COLOR:-0xffff3b30}" 2>/dev/null
else
  sketchybar --set "$NAME" drawing=off 2>/dev/null
fi
