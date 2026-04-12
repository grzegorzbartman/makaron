#!/bin/bash
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
THEME_DIR="$MAKARON_PATH/current-theme"
# shellcheck source=lib/screen_max_chars.sh
. "$CONFIG_DIR/plugins/lib/screen_max_chars.sh"

if [ -f "$HOME/.config/makaron/makaron.conf" ]; then
  # shellcheck disable=SC1090
  . "$HOME/.config/makaron/makaron.conf"
fi

SKETCHYBAR_TODOIST_ENABLED="${SKETCHYBAR_TODOIST_ENABLED:-true}"
[ "$SKETCHYBAR_TODOIST_ENABLED" = "false" ] && exit 0

if [ "$SENDER" = "display_change" ] || [ "$SENDER" = "system_woke" ]; then
  makaron_invalidate_screen_cache
fi

if [ -f "$THEME_DIR/sketchybar.colors" ]; then
  # shellcheck disable=SC1090
  . "$THEME_DIR/sketchybar.colors"
fi

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
TD_BIN="${TODOIST_CLI:-td}"
_max_chars=$(makaron_label_max_chars)

_smart_sort_first='
  [.[] | . + {
    _has_time: (if .due.datetime != null then 0 else 1 end),
    _time: (if .due.datetime != null then .due.datetime else (.due.date // "9999-12-31") + "T23:59:59Z" end),
    _prio: (-((.priority // 1)))
  }]
  | sort_by(._has_time, ._time, ._prio, .createdAt)
  | .[0].content // empty
'

_todoist_next_title() {
  if command -v "$TD_BIN" >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
    local json
    json=$("$TD_BIN" today --json --full 2>/dev/null) || return 1
    local t
    t=$(echo "$json" | jq -r '.results | sort_by(.dayOrder) | .[0].content // empty' 2>/dev/null) || return 1
    [ -n "$t" ] && echo "$t" && return 0
  fi
  local tok="${TODOIST_API_TOKEN:-}"
  [ -z "$tok" ] && return 1
  command -v curl >/dev/null 2>&1 || return 1
  command -v jq >/dev/null 2>&1 || return 1
  local json
  json=$(curl -sf -G "https://api.todoist.com/rest/v2/tasks" \
    -H "Authorization: Bearer ${tok}" \
    --data-urlencode "filter=today | overdue" 2>/dev/null) || return 1
  echo "$json" | jq -r "$_smart_sort_first" 2>/dev/null
}

title=$(_todoist_next_title)
title=$(echo "$title" | tr -d '\r' | head -c 500)

if [ -z "$title" ]; then
  sketchybar --set "$NAME" drawing=off 2>/dev/null || true
  exit 0
fi

sketchybar --set "$NAME" drawing=on \
  icon="󰄳" \
  icon.color="${ICON_COLOR:-0xffc0caf5}" \
  label.color="${LABEL_COLOR:-0xffc0caf5}" \
  label.max_chars="$_max_chars" \
  scroll_texts=on \
  label="$title" \
  click_script="open 'https://app.todoist.com/app/today'"
