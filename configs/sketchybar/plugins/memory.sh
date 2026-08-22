#!/bin/sh
# macOS memory for SketchyBar - always visible, matches Activity Monitor
# (makaron-memory-stats, Mach host_statistics64). Alert color above
# MEMORY_ALERT_THRESHOLD percent used.

MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
source "$CONFIG_DIR/colors.sh"

MEMORY_ALERT_THRESHOLD=80
[ -f "$HOME/.config/makaron/makaron.conf" ] && . "$HOME/.config/makaron/makaron.conf"
case "$MEMORY_ALERT_THRESHOLD" in (*[!0-9]*|"") MEMORY_ALERT_THRESHOLD=80 ;; esac

# Output format: "13.2/32 GB"
MEMORY_DISPLAY=$("$MAKARON_PATH/bin/makaron-memory-stats" 2>/dev/null || echo "N/A")
PCT=$(echo "$MEMORY_DISPLAY" | awk -F'[/ ]' 'NF>=2 && $2>0 {printf "%.0f", $1*100/$2}')

if [ -n "$PCT" ] && [ "$PCT" -ge "$MEMORY_ALERT_THRESHOLD" ] 2>/dev/null; then
  COLOR="${ALERT_COLOR:-0xffff3b30}"
else
  COLOR="${LABEL_COLOR:-0xffc0caf5}"
fi

sketchybar --set "$NAME" label="$MEMORY_DISPLAY" \
           --animate sin 15 --set "$NAME" \
  icon.color="$COLOR" label.color="$COLOR" 2>/dev/null
