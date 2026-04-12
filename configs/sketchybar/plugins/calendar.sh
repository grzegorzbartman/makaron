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

CAL_BIN="${MAKARON_PATH}/bin/makaron-calendar-next"
_label_from_icalbuddy() {
  command -v icalBuddy >/dev/null 2>&1 || return 1
  local line
  line=$(icalBuddy -n 1 -f "eventsToday+14" 2>/dev/null | head -1) || return 1
  [ -z "$line" ] && return 1
  echo "$line" | sed 's/^[•*[:space:]]*//'
}

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

_label_from_event() {
  local ts="$1"
  local title="$2"
  local when
  when=$(date -r "$ts" '+%H:%M' 2>/dev/null) || when=""

  if [ -n "$when" ] && [ "$_max_chars" -le 5 ]; then
    if [ "$when" = "00:00" ]; then
      echo "$title"
    else
      echo "$when"
    fi
    return
  fi

  if [ -n "$when" ]; then
    echo "$when $title"
  else
    echo "$title"
  fi
}

_truncate_label() {
  local text="$1"
  local max_chars="$2"
  [ -z "$text" ] && return 0
  [ -z "$max_chars" ] && echo "$text" && return 0
  printf '%s' "$text" | awk -v n="$max_chars" '{ print substr($0, 1, n) }'
}

event=$(_event_from_binary)
if [ -n "$event" ]; then
  ts=$(echo "$event" | cut -f1)
  title=$(echo "$event" | cut -f2-)
  line=$(_label_from_event "$ts" "$title")
else
  line=$(_label_from_icalbuddy)
fi

line=$(echo "$line" | tr -d '\r' | head -c 500)
line=$(_truncate_label "$line" "$_max_chars")

if [ -z "$line" ]; then
  sketchybar --set "$NAME" drawing=off 2>/dev/null || true
  exit 0
fi

sketchybar --set "$NAME" drawing=on \
  icon="󰃯" \
  icon.color="${ICON_COLOR:-0xffc0caf5}" \
  label.color="${LABEL_COLOR:-0xffc0caf5}" \
  label.max_chars="$_max_chars" \
  label="$line" \
  click_script="open -a Calendar"
