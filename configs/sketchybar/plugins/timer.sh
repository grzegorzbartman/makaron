#!/bin/bash
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
THEME_DIR="$MAKARON_PATH/current-theme"
# shellcheck source=lib/screen_max_chars.sh
. "$CONFIG_DIR/plugins/lib/screen_max_chars.sh"

if [ -f "$HOME/.config/makaron/makaron.conf" ]; then
  # shellcheck disable=SC1090
  . "$HOME/.config/makaron/makaron.conf"
fi

SKETCHYBAR_TIMER_ENABLED="${SKETCHYBAR_TIMER_ENABLED:-true}"
SKETCHYBAR_TIMER_RECENT_COUNT="${SKETCHYBAR_TIMER_RECENT_COUNT:-5}"
[ "$SKETCHYBAR_TIMER_ENABLED" = "false" ] && exit 0

if [ "$SENDER" = "display_change" ] || [ "$SENDER" = "system_woke" ]; then
  makaron_invalidate_screen_cache
fi

if [ -f "$THEME_DIR/sketchybar.colors" ]; then
  # shellcheck disable=SC1090
  . "$THEME_DIR/sketchybar.colors"
fi

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
TIMER_ITEM="timer"
POPUP_SLOTS=8

_popup_is_visible() {
  sketchybar --query "$TIMER_ITEM" 2>/dev/null | jq -r '.popup.drawing // "off"' 2>/dev/null
}

_hide_popup() {
  sketchybar --set "$TIMER_ITEM" popup.drawing=off 2>/dev/null || true
}

_trim_text() {
  local text="$1"
  local max_chars="$2"
  [ -z "$text" ] && return 0
  printf '%s' "$text" | awk -v n="$max_chars" '{ print substr($0, 1, n) }'
}

_render_main() {
  local status_json available active duration detail label label_max_chars
  local icon_color label_color icon_string accent_color
  local display_width main_max_chars detail_short

  status_json=$("$MAKARON_PATH/bin/makaron-timer" status 2>/dev/null || echo '{}')
  available=$(printf '%s' "$status_json" | jq -r '.available // false' 2>/dev/null)
  active=$(printf '%s' "$status_json" | jq -r '.active // false' 2>/dev/null)
  duration=$(printf '%s' "$status_json" | jq -r '.duration // ""' 2>/dev/null)
  detail=$(printf '%s' "$status_json" | jq -r '.detail // ""' 2>/dev/null)
  accent_color="${SPACE_FOCUSED_BORDER_COLOR:-${ICON_COLOR:-0xffc0caf5}}"

  display_width=$(makaron_min_display_width)
  main_max_chars=$(makaron_label_max_chars "$display_width")
  label_max_chars=18
  if [ "$main_max_chars" -lt "$label_max_chars" ]; then
    label_max_chars="$main_max_chars"
  fi

  if [ "$available" != "true" ]; then
    icon_string="󰅖"
    icon_color="0xffff9e64"
    label_color="0xffff9e64"
    label="install"
  elif [ "$active" = "true" ]; then
    icon_string="󱎫"
    icon_color="$accent_color"
    label_color="${LABEL_COLOR:-0xffc0caf5}"
    label="${duration:-on}"
    if [ "$main_max_chars" -ge 45 ] && [ -n "$detail" ]; then
      detail_short=$(_trim_text "$detail" 10)
      [ -n "$detail_short" ] && label="$label $detail_short"
    fi
  else
    icon_string="󱎫"
    icon_color="$accent_color"
    label_color="$accent_color"
    label="timer"
  fi

  sketchybar --set "$TIMER_ITEM" drawing=on \
    icon="$icon_string" \
    icon.color="$icon_color" \
    label.color="$label_color" \
    label.max_chars="$label_max_chars" \
    label="$label"
}

_render_popup() {
  local status_json active duration detail tag
  local today_json today_total today_entries
  local recent_json recent_count
  local slot=1 popup_max_chars=30

  status_json=$("$MAKARON_PATH/bin/makaron-timer" status 2>/dev/null || echo '{}')
  active=$(printf '%s' "$status_json" | jq -r '.active // false' 2>/dev/null)
  duration=$(printf '%s' "$status_json" | jq -r '.duration // ""' 2>/dev/null)
  detail=$(printf '%s' "$status_json" | jq -r '.detail // ""' 2>/dev/null)

  local accent_color="${SPACE_FOCUSED_BORDER_COLOR:-0xff7aa2f7}"
  local base_label="${LABEL_COLOR:-0xffc0caf5}"
  local dim_color="0x80${base_label:4}"

  # --- Header: Now ---
  local header
  if [ "$active" = "true" ] && [ -n "$duration" ]; then
    header="● $duration"
    [ -n "$detail" ] && header="$header — $(_trim_text "$detail" 16)"
    sketchybar --set "$TIMER_ITEM.popup.header" drawing=on label="$header" \
      label.color="$accent_color"
  else
    header="○ No active timer"
    sketchybar --set "$TIMER_ITEM.popup.header" drawing=on label="$header" \
      label.color="${LABEL_COLOR:-0xffc0caf5}"
  fi

  local label_color="${LABEL_COLOR:-0xffc0caf5}"

  # --- Slot 1: Today total ---
  today_json=$("$MAKARON_PATH/bin/makaron-timer" today 2>/dev/null || echo '{}')
  today_total=$(printf '%s' "$today_json" | jq -r '.total // "0:00"' 2>/dev/null)
  today_entries=$(printf '%s' "$today_json" | jq -r '.entries // 0' 2>/dev/null)
  sketchybar --set "$TIMER_ITEM.popup.$slot" drawing=on \
    label="Today: $today_total ($today_entries entries)" label.color="$label_color"
  slot=$((slot + 1))

  # --- Slot 2: Recent section header ---
  sketchybar --set "$TIMER_ITEM.popup.$slot" drawing=on label="── Recent ──" \
    label.color="$dim_color"
  slot=$((slot + 1))

  # --- Slots 3-6: Recent entries ---
  local recent_limit=4
  recent_json=$("$MAKARON_PATH/bin/makaron-timer" recent "$recent_limit" 2>/dev/null || echo '[]')
  recent_count=$(printf '%s' "$recent_json" | jq 'length' 2>/dev/null || echo 0)

  if [ "$recent_count" -eq 0 ]; then
    sketchybar --set "$TIMER_ITEM.popup.$slot" drawing=on label="  No entries yet" \
      label.color="$dim_color"
    slot=$((slot + 1))
  else
    local i=0
    while [ "$i" -lt "$recent_count" ] && [ "$i" -lt "$recent_limit" ]; do
      local entry dur_val title_val day_val row
      entry=$(printf '%s' "$recent_json" | jq -c ".[$i]" 2>/dev/null)
      dur_val=$(printf '%s' "$entry" | jq -r '.duration // ""' 2>/dev/null)
      title_val=$(printf '%s' "$entry" | jq -r '.title // ""' 2>/dev/null)
      day_val=$(printf '%s' "$entry" | jq -r '.day // ""' 2>/dev/null)

      row="  $dur_val $title_val"
      [ -n "$day_val" ] && [ "$day_val" != "Today" ] && row="$row  $day_val"
      row=$(_trim_text "$row" "$popup_max_chars")

      sketchybar --set "$TIMER_ITEM.popup.$slot" drawing=on label="$row" \
        label.color="$label_color"
      slot=$((slot + 1))
      i=$((i + 1))
    done
  fi

  # --- Action button ---
  local action_label action_cmd
  if [ "$active" = "true" ]; then
    action_label="■  Stop timer"
    action_cmd="stop"
  else
    action_label="▶  Start timer"
    action_cmd="start"
  fi

  sketchybar --set "$TIMER_ITEM.popup.$slot" drawing=on \
    label="$action_label" \
    label.color="$accent_color"
  sketchybar --set "$TIMER_ITEM.popup.$slot" \
    click_script="$MAKARON_PATH/bin/makaron-timer $action_cmd >/dev/null 2>&1; sketchybar --set $TIMER_ITEM popup.drawing=off"
  slot=$((slot + 1))

  # Hide remaining unused slots
  while [ "$slot" -le "$POPUP_SLOTS" ]; do
    sketchybar --set "$TIMER_ITEM.popup.$slot" drawing=off
    slot=$((slot + 1))
  done
}

_toggle_popup() {
  if [ "$(_popup_is_visible)" = "on" ]; then
    _hide_popup
    return 0
  fi

  _render_popup
  sketchybar --set "$TIMER_ITEM" popup.drawing=on
}

if [ "$SENDER" = "mouse.clicked" ]; then
  _toggle_popup
elif [ "$SENDER" = "space_change" ] || [ "$SENDER" = "display_change" ] || [ "$SENDER" = "front_app_switched" ]; then
  _hide_popup
fi

_render_main

if [ "$(_popup_is_visible)" = "on" ]; then
  _render_popup
fi
