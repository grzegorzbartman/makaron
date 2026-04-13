#!/bin/bash
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
THEME_DIR="$MAKARON_PATH/current-theme"
# shellcheck source=lib/screen_max_chars.sh
. "$CONFIG_DIR/plugins/lib/screen_max_chars.sh"

if [ -f "$HOME/.config/makaron/makaron.conf" ]; then
  # shellcheck disable=SC1090
  . "$HOME/.config/makaron/makaron.conf"
fi

SKETCHYBAR_CALENDAR_ENABLED="${SKETCHYBAR_CALENDAR_ENABLED:-true}"
[ "$SKETCHYBAR_CALENDAR_ENABLED" = "false" ] && exit 0

if [ "$SENDER" = "display_change" ] || [ "$SENDER" = "system_woke" ]; then
  makaron_invalidate_screen_cache
fi

if [ -f "$THEME_DIR/sketchybar.colors" ]; then
  # shellcheck disable=SC1090
  . "$THEME_DIR/sketchybar.colors"
fi

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
_display_width=$(makaron_min_display_width)
_max_chars=$(makaron_calendar_label_max_chars "$_display_width")
CALENDAR_ITEM="calendar"
CALENDAR_POPUP_SLOTS=10

CAL_BIN="${MAKARON_PATH}/bin/makaron-calendar-next"

_event_from_binary() {
  [ -x "$CAL_BIN" ] || return 1
  local out
  out=$("$CAL_BIN" 2>/dev/null) || return 1
  [ -z "$out" ] && return 1
  local ts title
  ts=$(echo "$out" | cut -f1)
  title=$(echo "$out" | cut -f2- | tr -d '\r' | head -c 500)
  [ -z "$title" ] && return 1
  printf '%s\t%s\n' "$ts" "$title"
}

_label_from_icalbuddy() {
  command -v icalBuddy >/dev/null 2>&1 || return 1
  local line
  line=$(icalBuddy -n 1 -f "eventsToday+14" 2>/dev/null | head -1) || return 1
  [ -z "$line" ] && return 1
  echo "$line" | sed 's/^[•*[:space:]]*//'
}

_today_events_from_binary() {
  [ -x "$CAL_BIN" ] || return 1
  "$CAL_BIN" --today 2>/dev/null
}

_label_from_event() {
  local ts="$1" title="$2" when
  when=$(date -r "$ts" '+%H:%M' 2>/dev/null) || when=""

  if [ -n "$when" ] && [ "$_max_chars" -le 5 ]; then
    [ "$when" = "00:00" ] && echo "$title" || echo "$when"
    return
  fi

  [ -n "$when" ] && echo "$when $title" || echo "$title"
}

_trim_text() {
  local text="$1" max="$2"
  [ -z "$text" ] && return 0
  printf '%s' "$text" | awk -v n="$max" '{ print substr($0, 1, n) }'
}

_popup_is_visible() {
  sketchybar --query "$CALENDAR_ITEM" 2>/dev/null | jq -r '.popup.drawing // "off"' 2>/dev/null
}

_hide_popup() {
  sketchybar --set "$CALENDAR_ITEM" popup.drawing=off 2>/dev/null || true
}

_render_popup() {
  local accent_color="${SPACE_FOCUSED_BORDER_COLOR:-0xff7aa2f7}"
  local label_color="${LABEL_COLOR:-0xffc0caf5}"
  local dim_color="0x80${label_color:4}"
  local slot=1

  sketchybar --set "$CALENDAR_ITEM.popup.$slot" drawing=on \
    label="Open Calendar" label.color="$accent_color"
  sketchybar --set "$CALENDAR_ITEM.popup.$slot" \
    click_script="open -a Calendar; sketchybar --set $CALENDAR_ITEM popup.drawing=off"
  slot=$((slot + 1))

  sketchybar --set "$CALENDAR_ITEM.popup.$slot" drawing=on label="── Today ──" \
    label.color="$dim_color" click_script=""
  slot=$((slot + 1))

  local events_raw count=0
  events_raw=$(_today_events_from_binary 2>/dev/null || true)

  if [ -z "$events_raw" ]; then
    sketchybar --set "$CALENDAR_ITEM.popup.$slot" drawing=on \
      label="  No events today" label.color="$dim_color" click_script=""
    slot=$((slot + 1))
  else
    while IFS=$'\t' read -r ts allday title; do
      [ -z "$title" ] && continue
      [ "$slot" -gt "$CALENDAR_POPUP_SLOTS" ] && break

      local time_str row
      if [ "$allday" = "1" ]; then
        time_str="All day"
      else
        time_str=$(date -r "$ts" '+%H:%M' 2>/dev/null || echo "")
      fi

      row="  $time_str  $(_trim_text "$title" 22)"

      sketchybar --set "$CALENDAR_ITEM.popup.$slot" drawing=on \
        label="$row" label.color="$label_color" click_script=""
      slot=$((slot + 1))
      count=$((count + 1))
    done <<< "$events_raw"

    if [ "$count" -eq 0 ]; then
      sketchybar --set "$CALENDAR_ITEM.popup.$slot" drawing=on \
        label="  No events today" label.color="$dim_color" click_script=""
      slot=$((slot + 1))
    fi
  fi

  while [ "$slot" -le "$CALENDAR_POPUP_SLOTS" ]; do
    sketchybar --set "$CALENDAR_ITEM.popup.$slot" drawing=off
    slot=$((slot + 1))
  done
}

_toggle_popup() {
  if [ "$(_popup_is_visible)" = "on" ]; then
    _hide_popup
    return 0
  fi
  _render_popup
  sketchybar --set "$CALENDAR_ITEM" popup.drawing=on
}

if [ "$SENDER" = "mouse.clicked" ]; then
  _toggle_popup
  exit 0
elif [ "$SENDER" = "space_change" ] || [ "$SENDER" = "front_app_switched" ]; then
  _hide_popup
fi

event=$(_event_from_binary)
if [ -n "$event" ]; then
  ts=$(echo "$event" | cut -f1)
  title=$(echo "$event" | cut -f2-)
  line=$(_label_from_event "$ts" "$title")
else
  line=$(_label_from_icalbuddy)
fi

line=$(echo "$line" | tr -d '\r' | head -c 500)
line=$(_trim_text "$line" "$_max_chars")

if [ -z "$line" ]; then
  sketchybar --set "$NAME" drawing=off 2>/dev/null || true
  exit 0
fi

sketchybar --set "$NAME" drawing=on \
  icon="󰃯" \
  icon.color="${ICON_COLOR:-0xffc0caf5}" \
  label.color="${LABEL_COLOR:-0xffc0caf5}" \
  label.max_chars="$_max_chars" \
  label="$line"
