#!/usr/bin/env bash

# This script highlights the focused AeroSpace workspace and shows app icons

WORKSPACE=$1
MONITOR=$2
PLUGIN_DIR="$(dirname "$0")"

# Sync workspaces: remove non-existent, add new ones (runs once per event via lock)
LOCK_FILE="/tmp/sketchybar_workspace_sync.lock"
if mkdir "$LOCK_FILE" 2>/dev/null; then
  trap "rmdir '$LOCK_FILE' 2>/dev/null" EXIT
  
  CURRENT_WS=$(aerospace list-workspaces --all 2>/dev/null)
  EXISTING=$(sketchybar --query bar 2>/dev/null | grep -o '"space\.[^"]*"' | tr -d '"' | sed 's/space\.//')
  
  # Remove items for workspaces that no longer exist
  for item in $EXISTING; do
    echo "$CURRENT_WS" | grep -qx "$item" || sketchybar --remove "space.$item" 2>/dev/null
  done
  
  # Add items for new workspaces (load colors first)
  MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
  if [ -f "$MAKARON_PATH/current-theme/sketchybar.colors" ]; then
    source "$MAKARON_PATH/current-theme/sketchybar.colors"
  fi
  
  for ws in $CURRENT_WS; do
    if ! echo "$EXISTING" | grep -qx "$ws"; then
      sketchybar --add item space.$ws left \
        --subscribe space.$ws aerospace_workspace_change front_app_switched \
        --set space.$ws icon="$ws" icon.padding_left=8 icon.padding_right=8 \
        icon.color="${SPACE_ICON_COLOR:-0xffa9b1d6}" label.padding_left=6 label.padding_right=6 \
        label.font="Hack Nerd Font:Bold:11.0" label.color="${SPACE_LABEL_COLOR:-0xffa9b1d6}" \
        background.color="${SPACE_BACKGROUND_COLOR:-0xff24283b}" background.corner_radius=8 \
        background.height=28 background.drawing=on background.border_color="${SPACE_BORDER_COLOR:-0xff3b4261}" \
        script="$PLUGIN_DIR/aerospace.sh $ws" click_script="aerospace workspace $ws"
    fi
  done
  
  rmdir "$LOCK_FILE" 2>/dev/null
  trap - EXIT
fi

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
"Telegram") echo "" ;;
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

# Load theme colors
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
THEME_DIR="$MAKARON_PATH/current-theme"
if [ -f "$THEME_DIR/sketchybar.colors" ]; then
  source "$THEME_DIR/sketchybar.colors"
fi

# Multi-monitor support: Check if this workspace is visible on its assigned monitor
# In multi-monitor setup, we need to check per-monitor visibility, not global focus
if [[ -n "$MONITOR" ]]; then
  # Get the visible workspace for this specific monitor
  VISIBLE_ON_MONITOR=$(aerospace list-workspaces --monitor "$MONITOR" --visible 2>/dev/null)
  IS_FOCUSED="$VISIBLE_ON_MONITOR"
else
  # Fallback for single monitor or legacy behavior
  # Get focused workspace from environment variable (set by aerospace exec-on-workspace-change)
  # If not set (e.g., from front_app_switched event), query aerospace
  if [[ -z "$FOCUSED_WORKSPACE" ]]; then
    FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null)
  fi
  IS_FOCUSED="$FOCUSED_WORKSPACE"
fi

if [[ "$IS_FOCUSED" == "$WORKSPACE" ]]; then
# Focused workspace - theme colors
sketchybar --set "$NAME" \
  background.drawing=on \
  background.color="${SPACE_FOCUSED_BACKGROUND_COLOR:-0xff1a1b26}" \
  background.border_color="${SPACE_FOCUSED_BORDER_COLOR:-0xff7aa2f7}" \
  background.border_width=2 \
  icon.color="${SPACE_FOCUSED_ICON_COLOR:-0xffc0caf5}" \
  label.color="${SPACE_FOCUSED_LABEL_COLOR:-0xffc0caf5}"
else
# Inactive workspace - theme colors
sketchybar --set "$NAME" \
  background.drawing=on \
  background.color="${SPACE_BACKGROUND_COLOR:-0xff24283b}" \
  background.border_color="${SPACE_BORDER_COLOR:-0xff3b4261}" \
  background.border_width=1 \
  icon.color="${SPACE_ICON_COLOR:-0xffa9b1d6}" \
  label.color="${SPACE_LABEL_COLOR:-0xffa9b1d6}"
fi

# Get windows in this workspace and extract unique app names
windows=$(aerospace list-windows --workspace "$WORKSPACE" 2>/dev/null | awk -F'|' '{print $2}' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sort -u)

# Build icon string
icons=""
while IFS= read -r app; do
if [[ -n "$app" ]]; then
icon=$(get_app_icon "$app")
if [[ -n "$icons" ]]; then
icons="$icons $icon" # Add space between icons
else
icons="$icon"
fi
fi
done <<< "$windows"

    # Update the label with app icons
    if [[ -n "$icons" ]]; then
    sketchybar --set "$NAME" label="$icons" label.drawing=on
    else
    # Hide label when workspace is empty but keep workspace visible
    sketchybar --set "$NAME" label="" label.drawing=off
    fi
