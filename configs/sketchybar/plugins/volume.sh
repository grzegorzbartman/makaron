#!/bin/sh

# The volume_change event supplies a $INFO variable in which the current volume
# percentage is passed to the script.

# Load theme colors
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
THEME_DIR="$MAKARON_PATH/current-theme"
if [ -f "$THEME_DIR/sketchybar.colors" ]; then
  source "$THEME_DIR/sketchybar.colors"
fi

CACHE_FILE="/tmp/sketchybar_audio_device"
CACHE_DURATION=5  # seconds

if [ "$SENDER" = "volume_change" ]; then
  VOLUME="$INFO"

  # Check if the default output device is Bluetooth (headphones)
  IS_HEADPHONES=false

  # Use cached result if available and recent (within 5 seconds)
  if [ -f "$CACHE_FILE" ] && [ $(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0))) -lt $CACHE_DURATION ]; then
    IS_HEADPHONES=$(cat "$CACHE_FILE")
  else
    # Query audio device info (slow operation)
    AUDIO_INFO=$(system_profiler SPAudioDataType 2>/dev/null)

    # Look for "Transport: Bluetooth" within the Default Output Device section
    if echo "$AUDIO_INFO" | grep -A 5 "Default Output Device: Yes" | grep -q "Transport: Bluetooth"; then
      IS_HEADPHONES=true
    fi

    # Cache the result
    echo "$IS_HEADPHONES" > "$CACHE_FILE"
  fi

  # Choose icon based on device type and volume
  if [ "$IS_HEADPHONES" = true ]; then
    # Headphone icons
    case "$VOLUME" in
      [6-9][0-9]|100) ICON="󰋋"  # Headphones high
      ;;
      [3-5][0-9]) ICON="󰋋"       # Headphones medium
      ;;
      [1-9]|[1-2][0-9]) ICON="󰋋" # Headphones low
      ;;
      *) ICON="󰟎"                # Headphones muted
    esac
  else
    # Speaker icons (original)
    case "$VOLUME" in
      [6-9][0-9]|100) ICON="󰕾"
      ;;
      [3-5][0-9]) ICON="󰖀"
      ;;
      [1-9]|[1-2][0-9]) ICON="󰕿"
      ;;
      *) ICON="󰖁"
    esac
  fi

  sketchybar --set "$NAME" icon="$ICON" label="$VOLUME%" \
    icon.color="${ICON_COLOR:-0xffc0caf5}" \
    label.color="${LABEL_COLOR:-0xffc0caf5}"
fi
