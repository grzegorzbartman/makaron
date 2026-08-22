#!/bin/sh
# Storage alert for SketchyBar (APFS-aware): hidden below the threshold,
# shown as a warning when the disk is nearly full.

source "$CONFIG_DIR/colors.sh"

STORAGE_ALERT_THRESHOLD=90
[ -f "$HOME/.config/makaron/makaron.conf" ] && . "$HOME/.config/makaron/makaron.conf"
case "$STORAGE_ALERT_THRESHOLD" in (*[!0-9]*|"") STORAGE_ALERT_THRESHOLD=90 ;; esac

USED_PCT=$(df -H /System/Volumes/Data 2>/dev/null | tail -1 | awk '{print $5}' | tr -d '%')
case "$USED_PCT" in (*[!0-9]*|"") USED_PCT=0 ;; esac

if [ "$USED_PCT" -gt "$STORAGE_ALERT_THRESHOLD" ]; then
  sketchybar --set "$NAME" drawing=on label="${USED_PCT}% full" \
    icon.color="${SPACE_FOCUSED_BORDER_COLOR:-0xffff5555}" \
    label.color="${SPACE_FOCUSED_BORDER_COLOR:-0xffff5555}" 2>/dev/null
else
  sketchybar --set "$NAME" drawing=off 2>/dev/null
fi
