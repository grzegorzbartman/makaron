#!/bin/sh

MAKARON_CONF="$HOME/.config/makaron/makaron.conf"

source "$CONFIG_DIR/colors.sh"

# Load user config
BATTERY_LOW_THRESHOLD=20
if [ -f "$MAKARON_CONF" ]; then
  source "$MAKARON_CONF"
fi

PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

case "${PERCENTAGE}" in
  9[0-9]|100) ICON="󰁹"
  ;;
  [6-8][0-9]) ICON="󰂀"
  ;;
  [3-5][0-9]) ICON="󰁾"
  ;;
  [1-2][0-9]) ICON="󰁻"
  ;;
  *) ICON="󰂃"
esac

if [[ "$CHARGING" != "" ]]; then
  ICON="󰂄"
fi

# Determine colors - use focused border color for low battery warning
if [ "$PERCENTAGE" -le "$BATTERY_LOW_THRESHOLD" ] && [ -z "$CHARGING" ]; then
  DISPLAY_ICON_COLOR="${SPACE_FOCUSED_BORDER_COLOR:-0xffff5555}"
  DISPLAY_LABEL_COLOR="${SPACE_FOCUSED_BORDER_COLOR:-0xffff5555}"
else
  DISPLAY_ICON_COLOR="${ICON_COLOR:-0xffc0caf5}"
  DISPLAY_LABEL_COLOR="${LABEL_COLOR:-0xffc0caf5}"
fi

sketchybar --set "$NAME" icon="$ICON" label="${PERCENTAGE}%" \
  icon.color="$DISPLAY_ICON_COLOR" \
  label.color="$DISPLAY_LABEL_COLOR"
