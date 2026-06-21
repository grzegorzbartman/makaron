#!/usr/bin/env bash

# This script highlights the focused AeroSpace workspace and shows app icons

WORKSPACE=$1
MONITOR=$2

# Map app names to icons (using Nerd Font icons)
get_app_icon() {
case "$1" in
"kitty"|"Alacritty"|"iTerm2"|"Terminal"|"WezTerm"|"Ghostty") echo "" ;;
"Safari"|"safari") echo "󰀹" ;;
"Google Chrome"|"Chrome"|"Chromium") echo "" ;;
"Firefox"|"Firefox Developer Edition") echo "" ;;
"Arc") echo "" ;;
"Brave Browser") echo "󰖟" ;;
"Code"|"Visual Studio Code"|"VSCodium") echo "󰨞" ;;
"Cursor") echo "󰨞" ;;
"Finder") echo "" ;;
"Mail"|"Mimestream") echo "" ;;
"Calendar"|"Fantastical") echo "" ;;
"Home") echo "󱉑" ;;
"Messages") echo "󰍦" ;;
"Slack") echo "" ;;
"Discord") echo "󰙯" ;;
"ChatGPT") echo "󰭹" ;;
"Claude") echo "󰚩" ;;
"Telegram"|"Telegram Desktop"|"Telegram Lite") echo "" ;;
"WhatsApp") echo "" ;;
"Spotify"|"Music") echo "" ;;
"Notes") echo "" ;;
"Todoist") echo "" ;;
"Obsidian") echo "󱓷" ;;
"Notion") echo "󰈚" ;;
"Preview") echo "󰋩" ;;
"Photoshop") echo "" ;;
"Illustrator") echo "" ;;
"Figma") echo "" ;;
"IntelliJ IDEA"|"IntelliJ IDEA CE") echo "" ;;
"PHPStorm") echo "" ;;
"PyCharm"|"PyCharm CE") echo "" ;;
"WebStorm") echo "" ;;
"Android Studio") echo "" ;;
"Xcode") echo "" ;;
"Docker"|"Docker Desktop") echo "" ;;
"Postman") echo "󰘯" ;;
"TablePlus"|"Sequel Pro"|"DBeaver") echo "" ;;
"VLC") echo "󰕼" ;;
"IINA") echo "󰕼" ;;
"Zoom"|"zoom.us") echo "󰍩" ;;
"Microsoft Teams") echo "󰊻" ;;
"System Settings"|"System Preferences") echo "" ;;
"App Store") echo "" ;;
"TV") echo "" ;;
"Activity Monitor") echo "" ;;
*) echo "󰀏" ;; # Default icon for unknown apps
esac
}

source "$CONFIG_DIR/colors.sh"

# Optional user flag: hide empty, non-focused workspaces from the bar.
# Focused workspace is always drawn so users never "lose" their position.
if [ -f "$HOME/.config/makaron/makaron.conf" ]; then
  # shellcheck disable=SC1090
  source "$HOME/.config/makaron/makaron.conf"
fi
SKETCHYBAR_HIDE_EMPTY_WORKSPACES="${SKETCHYBAR_HIDE_EMPTY_WORKSPACES:-false}"

# Selective refresh: when AeroSpace reports a workspace change, only the
# previous and the newly focused workspaces actually need to be redrawn.
# All other event senders (focus change inside a workspace, front_app_switched,
# manual --update, etc.) fall through to the full refresh path.
if [[ "$SENDER" == "aerospace_workspace_change" ]]; then
  if [[ "$WORKSPACE" != "$FOCUSED_WORKSPACE" && "$WORKSPACE" != "$PREV_WORKSPACE" ]]; then
    exit 0
  fi
fi

# Multi-monitor support: Check if this workspace is visible on its assigned monitor
# In multi-monitor setup, we need to check per-monitor visibility, not global focus
if [[ -n "$MONITOR" ]]; then
  VISIBLE_ON_MONITOR=$(aerospace list-workspaces --monitor "$MONITOR" --visible 2>/dev/null)
  IS_FOCUSED="$VISIBLE_ON_MONITOR"
else
  # Single-monitor fallback: prefer event payload, otherwise query aerospace.
  if [[ -z "$FOCUSED_WORKSPACE" ]]; then
    FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null)
  fi
  IS_FOCUSED="$FOCUSED_WORKSPACE"
fi

if [[ "$IS_FOCUSED" == "$WORKSPACE" ]]; then
  sketchybar --set "$NAME" \
    background.drawing=on \
    background.color="${SPACE_FOCUSED_BACKGROUND_COLOR:-0xff1a1b26}" \
    background.border_color="${SPACE_FOCUSED_BORDER_COLOR:-0xff7aa2f7}" \
    background.border_width=2 \
    icon.color="${SPACE_FOCUSED_ICON_COLOR:-0xffc0caf5}" \
    label.color="${SPACE_FOCUSED_LABEL_COLOR:-0xffc0caf5}"
else
  sketchybar --set "$NAME" \
    background.drawing=on \
    background.color="${SPACE_BACKGROUND_COLOR:-0xff24283b}" \
    background.border_width=0 \
    icon.color="${SPACE_ICON_COLOR:-0xffa9b1d6}" \
    label.color="${SPACE_LABEL_COLOR:-0xffa9b1d6}"
fi

# Collect unique app names for the workspace and turn them into icons.
windows=$(aerospace list-windows --workspace "$WORKSPACE" 2>/dev/null | awk -F'|' '{print $2}' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sort -u)

icons=""
while IFS= read -r app; do
  if [[ -n "$app" ]]; then
    icon=$(get_app_icon "$app")
    if [[ -n "$icons" ]]; then
      icons="$icons $icon"
    else
      icons="$icon"
    fi
  fi
done <<< "$windows"

if [[ -n "$icons" ]]; then
  sketchybar --set "$NAME" drawing=on label="$icons" label.drawing=on
else
  if [[ "$SKETCHYBAR_HIDE_EMPTY_WORKSPACES" == "true" && "$IS_FOCUSED" != "$WORKSPACE" ]]; then
    sketchybar --set "$NAME" drawing=off
  else
    sketchybar --set "$NAME" drawing=on label="" label.drawing=off
  fi
fi
