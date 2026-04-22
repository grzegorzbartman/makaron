#!/bin/bash
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
THEME_DIR="$MAKARON_PATH/current-theme"

if [ -f "$HOME/.config/makaron/makaron.conf" ]; then
  # shellcheck disable=SC1090
  . "$HOME/.config/makaron/makaron.conf"
fi

if [ -f "$THEME_DIR/sketchybar.colors" ]; then
  # shellcheck disable=SC1090
  . "$THEME_DIR/sketchybar.colors"
fi

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
TOOLS_ITEM="tools"
POPUP_SLOTS=6

_popup_is_visible() {
  sketchybar --query "$TOOLS_ITEM" 2>/dev/null | jq -r '.popup.drawing // "off"' 2>/dev/null
}

_hide_popup() {
  sketchybar --set "$TOOLS_ITEM" popup.drawing=off 2>/dev/null || true
}

_new_apple_note() {
  local current_ws
  current_ws=$(aerospace list-workspaces --focused 2>/dev/null)

  osascript <<'APPLESCRIPT' &>/dev/null
tell application "Notes"
  activate
  set n to make new note
  show n
end tell
delay 0.5
tell application "System Events" to tell process "Notes"
  try
    set wMenu to last menu bar item of menu bar 1 whose title is not "Help" and title is not "Pomoc"
    set items_list to name of every menu item of menu 1 of wMenu
    repeat with i from 1 to count of items_list
      set itemName to item i of items_list
      if itemName is not missing value then
        if itemName contains "New Window" or itemName contains "nowym oknie" or itemName contains "Float" then
          click menu item itemName of menu 1 of wMenu
          exit repeat
        end if
      end if
    end repeat
  end try
end tell
APPLESCRIPT

  sleep 0.3
  if [ -n "$current_ws" ]; then
    aerospace move-node-to-workspace "$current_ws" 2>/dev/null
    aerospace workspace "$current_ws" 2>/dev/null
  fi
}

_render_popup() {
  local accent_color="${SPACE_FOCUSED_BORDER_COLOR:-0xff7aa2f7}"
  local label_color="${LABEL_COLOR:-0xffc0caf5}"
  local slot=1

  sketchybar --set "$TOOLS_ITEM.popup.$slot" drawing=on \
    label="󰎞  New Apple Note" label.color="$accent_color"
  sketchybar --set "$TOOLS_ITEM.popup.$slot" \
    click_script="$MAKARON_PATH/configs/sketchybar/plugins/tools.sh --action new-note; sketchybar --set $TOOLS_ITEM popup.drawing=off"
  slot=$((slot + 1))

  while [ "$slot" -le "$POPUP_SLOTS" ]; do
    sketchybar --set "$TOOLS_ITEM.popup.$slot" drawing=off
    slot=$((slot + 1))
  done
}

_toggle_popup() {
  if [ "$(_popup_is_visible)" = "on" ]; then
    _hide_popup
    return 0
  fi
  _render_popup
  sketchybar --set "$TOOLS_ITEM" popup.drawing=on
}

if [ "${1:-}" = "--action" ]; then
  case "${2:-}" in
    new-note) _new_apple_note ;;
  esac
  exit 0
fi

if [ "$SENDER" = "mouse.clicked" ]; then
  _toggle_popup
  exit 0
elif [ "$SENDER" = "space_change" ] || [ "$SENDER" = "front_app_switched" ]; then
  _hide_popup
fi

sketchybar --set "$NAME" drawing=on \
  icon="󰀻" \
  icon.color="${ICON_COLOR:-0xffc0caf5}"
