#!/bin/sh
# CPU usage percentage for SketchyBar (warning color under heavy load)

source "$CONFIG_DIR/colors.sh"

CPU_CORES=$(sysctl -n hw.ncpu)
# Sum of per-process %cpu (decaying average, instant read) over core count
CPU_SUM=$(ps -A -o %cpu | awk '{s+=$1} END {printf "%.0f", s}')

if [ -z "$CPU_SUM" ] || [ -z "$CPU_CORES" ] || [ "$CPU_CORES" -eq 0 ] 2>/dev/null; then
  CPU_DISPLAY="N/A"
  COLOR="${LABEL_COLOR:-0xffc0caf5}"
else
  CPU_PCT=$((CPU_SUM / CPU_CORES))
  [ "$CPU_PCT" -gt 100 ] && CPU_PCT=100
  CPU_DISPLAY="${CPU_PCT}%"
  if [ "$CPU_PCT" -gt 80 ]; then
    COLOR="${SPACE_FOCUSED_BORDER_COLOR:-0xffff5555}"
  else
    COLOR="${LABEL_COLOR:-0xffc0caf5}"
  fi
fi

sketchybar --set "$NAME" label="$CPU_DISPLAY" label.color="$COLOR" 2>/dev/null || {
  echo "Error updating CPU display" >&2
  exit 1
}
