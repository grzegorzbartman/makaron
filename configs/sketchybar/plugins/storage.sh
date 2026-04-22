#!/bin/sh
# Storage usage for SketchyBar (APFS-aware)

# Load theme colors
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
THEME_DIR="$MAKARON_PATH/current-theme"
if [ -f "$THEME_DIR/sketchybar.colors" ]; then
  source "$THEME_DIR/sketchybar.colors"
fi

# Get disk usage for Data volume (actual user data on APFS)
DISK_INFO=$(df -H /System/Volumes/Data 2>/dev/null | tail -1 | awk '{print $3, $2}')
USED=$(echo "$DISK_INFO" | awk '{print $1}' | tr -d 'G')
TOTAL=$(echo "$DISK_INFO" | awk '{print $2}' | tr -d 'G')

# Format display
if [ -z "$USED" ] || [ -z "$TOTAL" ]; then
  STORAGE_DISPLAY="N/A"
else
  STORAGE_DISPLAY="${USED}/${TOTAL} GB"
fi

sketchybar --set "$NAME" label="$STORAGE_DISPLAY" \
  label.color="${LABEL_COLOR:-0xffc0caf5}" 2>/dev/null
