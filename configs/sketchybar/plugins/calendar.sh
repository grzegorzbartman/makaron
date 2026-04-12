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
_max_chars=$(makaron_label_max_chars)

CAL_BIN="${MAKARON_PATH}/bin/makaron-calendar-next"
_label_from_icalbuddy() {
  command -v icalBuddy >/dev/null 2>&1 || return 1
  local line
  line=$(icalBuddy -n 1 -f "eventsToday+14" 2>/dev/null | head -1) || return 1
  [ -z "$line" ] && return 1
  echo "$line" | sed 's/^[•*[:space:]]*//'
}

_label_from_binary() {
  [ -x "$CAL_BIN" ] || return 1
  local out
  out=$("$CAL_BIN" 2>/dev/null) || return 1
  [ -z "$out" ] && return 1
  local ts title
  ts=$(echo "$out" | cut -f1)
  title=$(echo "$out" | cut -f2-)
  [ -z "$title" ] && return 1
  local when
  when=$(date -r "$ts" '+%H:%M' 2>/dev/null) || when=""
  [ -n "$when" ] && echo "$when $title" || echo "$title"
}

line=$(_label_from_binary)
[ -z "$line" ] && line=$(_label_from_icalbuddy)

line=$(echo "$line" | tr -d '\r' | head -c 500)

if [ -z "$line" ]; then
  sketchybar --set "$NAME" drawing=off 2>/dev/null || true
  exit 0
fi

sketchybar --set "$NAME" drawing=on \
  icon="󰃯" \
  icon.color="${ICON_COLOR:-0xffc0caf5}" \
  label.color="${LABEL_COLOR:-0xffc0caf5}" \
  label.max_chars="$_max_chars" \
  scroll_texts=on \
  label="$line" \
  click_script="open -a Calendar"
