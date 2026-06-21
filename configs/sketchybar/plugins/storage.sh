#!/bin/sh
# Storage usage for SketchyBar (APFS-aware)

source "$CONFIG_DIR/colors.sh"

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
