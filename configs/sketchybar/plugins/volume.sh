#!/bin/sh
# Volume for SketchyBar. Idle state is a quiet icon; on a volume change or an
# output-device switch (speakers <-> bluetooth) the section lights up in the
# accent color with the percent label for 3 seconds, then eases back.

source "$CONFIG_DIR/colors.sh"

CACHE_FILE="/tmp/sketchybar_$(id -u)_audio_device"
CACHE_DURATION=5  # seconds
DEVICE_FILE="/tmp/sketchybar_$(id -u)_volume_out_device"
TS_FILE="/tmp/sketchybar_$(id -u)_volume_ts"

ACCENT="${SPACE_FOCUSED_BACKGROUND_COLOR:-0xff007aff}"
IDLE_ICON="${ICON_COLOR:-0xffc0caf5}"

if [ "$SENDER" = "volume_change" ]; then
  VOLUME="$INFO"
  VOLUME_CHANGED=true
else
  # Periodic/forced run: read volume, watch for output-device switches
  VOLUME=$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)
  case "$VOLUME" in (*[!0-9]*|"") exit 0 ;; esac
  VOLUME_CHANGED=false
fi

# Detect the output device (cached - system_profiler is slow)
IS_HEADPHONES=false
if [ -f "$CACHE_FILE" ] && [ $(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0))) -lt $CACHE_DURATION ]; then
  IS_HEADPHONES=$(cat "$CACHE_FILE")
else
  AUDIO_INFO=$(system_profiler SPAudioDataType 2>/dev/null)
  if echo "$AUDIO_INFO" | grep -A 5 "Default Output Device: Yes" | grep -q "Transport: Bluetooth"; then
    IS_HEADPHONES=true
  fi
  echo "$IS_HEADPHONES" > "$CACHE_FILE"
fi

# Device switch since the last render? (first run only records)
PREV_DEVICE=$(cat "$DEVICE_FILE" 2>/dev/null)
echo "$IS_HEADPHONES" > "$DEVICE_FILE"
DEVICE_CHANGED=false
if [ -n "$PREV_DEVICE" ] && [ "$PREV_DEVICE" != "$IS_HEADPHONES" ]; then
  DEVICE_CHANGED=true
fi

if [ "$IS_HEADPHONES" = true ]; then
  case "$VOLUME" in
    0|"") ICON="󰟎" ;;
    *) ICON="󰋋" ;;
  esac
else
  case "$VOLUME" in
    [6-9][0-9]|100) ICON="󰕾" ;;
    [3-5][0-9]) ICON="󰖀" ;;
    [1-9]|[1-2][0-9]) ICON="󰕿" ;;
    *) ICON="󰖁" ;;
  esac
fi

if [ "$VOLUME_CHANGED" = true ] || [ "$DEVICE_CHANGED" = true ]; then
  # Light up in accent for 3s (timestamp-guarded against rapid scrubbing)
  TS=$(date +%s%N 2>/dev/null || date +%s)
  echo "$TS" > "$TS_FILE"
  sketchybar --set "$NAME" icon="$ICON" label="$VOLUME%" label.drawing=on \
             --animate sin 12 --set "$NAME" icon.color="$ACCENT" label.color="$ACCENT"
  (
    sleep 3
    if [ "$(cat "$TS_FILE" 2>/dev/null)" = "$TS" ]; then
      sketchybar --animate sin 20 --set "$NAME" icon.color="$IDLE_ICON" \
                 --set "$NAME" label.drawing=off
    fi
  ) &
else
  # Idle refresh: never clobber an active highlight
  LAST_TS=$(cat "$TS_FILE" 2>/dev/null)
  if [ -n "$LAST_TS" ]; then
    NOW=$(date +%s%N 2>/dev/null || date +%s)
    [ $((NOW - LAST_TS)) -lt 3000000000 ] 2>/dev/null && exit 0
  fi
  sketchybar --set "$NAME" icon="$ICON" icon.color="$IDLE_ICON" label.drawing=off
fi
