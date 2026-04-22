#!/bin/sh
# CPU load average and core count for SketchyBar

# Load theme colors
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
THEME_DIR="$MAKARON_PATH/current-theme"
if [ -f "$THEME_DIR/sketchybar.colors" ]; then
  source "$THEME_DIR/sketchybar.colors"
fi

# Get number of CPU cores
CPU_CORES=$(sysctl -n hw.ncpu)

# Get 1-minute load average
LOAD_AVERAGE=$(uptime | awk -F'load averages:' '{print $2}' | awk '{print $1}' | sed 's/,//')

# Round load average to 2 decimal places
LOAD_ROUNDED=$(echo "$LOAD_AVERAGE" | awk '{printf "%.2f", $1}')

# Error handling for invalid values
if [ -z "$LOAD_ROUNDED" ] || [ -z "$CPU_CORES" ] || ! [[ "$LOAD_ROUNDED" =~ ^[0-9]+\.?[0-9]*$ ]] || ! [[ "$CPU_CORES" =~ ^[0-9]+$ ]]; then
  CPU_DISPLAY="N/A"
else
  CPU_DISPLAY="${LOAD_ROUNDED}/${CPU_CORES}"
fi

# Update SketchyBar with error handling
sketchybar --set "$NAME" label="$CPU_DISPLAY" \
  label.color="${LABEL_COLOR:-0xffc0caf5}" 2>/dev/null || {
  echo "Error updating CPU display" >&2
  exit 1
}
