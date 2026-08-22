#!/bin/sh
# CPU usage percent for SketchyBar - always visible, alert color above
# CPU_ALERT_THRESHOLD.

source "$CONFIG_DIR/colors.sh"

CPU_ALERT_THRESHOLD=80
[ -f "$HOME/.config/makaron/makaron.conf" ] && . "$HOME/.config/makaron/makaron.conf"
case "$CPU_ALERT_THRESHOLD" in (*[!0-9]*|"") CPU_ALERT_THRESHOLD=80 ;; esac

CPU_CORES=$(sysctl -n hw.ncpu)
CPU_SUM=$(ps -A -o %cpu | awk '{s+=$1} END {printf "%.0f", s}')

if [ -z "$CPU_SUM" ] || [ -z "$CPU_CORES" ] || [ "$CPU_CORES" -eq 0 ] 2>/dev/null; then
  sketchybar --set "$NAME" label="N/A" 2>/dev/null
  exit 0
fi
CPU_PCT=$((CPU_SUM / CPU_CORES))
[ "$CPU_PCT" -gt 100 ] && CPU_PCT=100

if [ "$CPU_PCT" -ge "$CPU_ALERT_THRESHOLD" ]; then
  COLOR="${ALERT_COLOR:-0xffff3b30}"
else
  COLOR="${LABEL_COLOR:-0xffc0caf5}"
fi

sketchybar --set "$NAME" label="${CPU_PCT}%" \
           --animate sin 15 --set "$NAME" \
  icon.color="$COLOR" label.color="$COLOR" 2>/dev/null
