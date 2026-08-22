#!/bin/sh
# CPU alert for SketchyBar: hidden below CPU_ALERT_THRESHOLD, shown as a
# warning pill when the CPU is under sustained heavy load.

source "$CONFIG_DIR/colors.sh"

CPU_ALERT_THRESHOLD=80
[ -f "$HOME/.config/makaron/makaron.conf" ] && . "$HOME/.config/makaron/makaron.conf"
case "$CPU_ALERT_THRESHOLD" in (*[!0-9]*|"") CPU_ALERT_THRESHOLD=80 ;; esac

CPU_CORES=$(sysctl -n hw.ncpu)
CPU_SUM=$(ps -A -o %cpu | awk '{s+=$1} END {printf "%.0f", s}')

[ -z "$CPU_SUM" ] || [ -z "$CPU_CORES" ] || [ "$CPU_CORES" -eq 0 ] 2>/dev/null && exit 0
CPU_PCT=$((CPU_SUM / CPU_CORES))
[ "$CPU_PCT" -gt 100 ] && CPU_PCT=100

if [ "$CPU_PCT" -ge "$CPU_ALERT_THRESHOLD" ]; then
  sketchybar --set "$NAME" drawing=on label="${CPU_PCT}%" \
    background.color="${ALERT_BACKGROUND_COLOR:-0x26ff3b30}" \
    icon.color="${ALERT_COLOR:-0xffff3b30}" \
    label.color="${ALERT_COLOR:-0xffff3b30}" 2>/dev/null
else
  sketchybar --set "$NAME" drawing=off 2>/dev/null
fi
