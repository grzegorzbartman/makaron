#!/bin/sh

# The $NAME variable is passed from sketchybar and holds the name of
# the item invoking this script:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

source "$CONFIG_DIR/colors.sh"

sketchybar --set "$NAME" label="$(date '+%a | %Y-%m-%d | %H:%M')" \
  label.color="${LABEL_COLOR:-0xffc0caf5}"

