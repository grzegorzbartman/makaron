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
_max_chars=$(makaron_label_max_chars)
TODOIST_ITEM="todoist"
TODOIST_POPUP_SLOTS=10

_find_td_bin() {
  local candidate

  if [ -n "${TODOIST_CLI:-}" ] && [ -x "$TODOIST_CLI" ]; then
    echo "$TODOIST_CLI"
    return 0
  fi

  candidate=$(command -v td 2>/dev/null)
  if [ -n "$candidate" ] && [ -x "$candidate" ]; then
    echo "$candidate"
    return 0
  fi

  for candidate in \
    "$HOME/.nvm/versions/node"/*/bin/td \
    "$HOME/.fnm/node-versions"/*/installation/bin/td \
    "$HOME/Library/Application Support/fnm/node-versions"/*/installation/bin/td \
    "$HOME/.volta/bin/td" \
    "$HOME/.npm-global/bin/td"
  do
    if [ -x "$candidate" ]; then
      echo "$candidate"
      return 0
    fi
  done

  return 1
}

TD_BIN=$(_find_td_bin 2>/dev/null || true)

_smart_sort='
  [.results[] | . + {
    _has_time: (if .due.datetime != null then 0 else 1 end),
    _time: (if .due.datetime != null then .due.datetime else "9999-12-31T23:59:59Z" end),
    _prio: (-((.priority // 1)))
  }]
  | sort_by(._has_time, ._prio, ._time, .dayOrder)
'

_todoist_all_tasks_json() {
  if [ -n "$TD_BIN" ] && [ -x "$TD_BIN" ] && command -v jq >/dev/null 2>&1; then
    local json
    json=$("$TD_BIN" today --json --full 2>/dev/null) || return 1
    echo "$json" | jq -c "$_smart_sort" 2>/dev/null
    return $?
  fi
  local tok="${TODOIST_API_TOKEN:-}"
  [ -z "$tok" ] && return 1
  command -v curl >/dev/null 2>&1 || return 1
  command -v jq >/dev/null 2>&1 || return 1
  local json
  json=$(curl -sf -G "https://api.todoist.com/rest/v2/tasks" \
    -H "Authorization: Bearer ${tok}" \
    --data-urlencode "filter=today | overdue" 2>/dev/null) || return 1
  echo "$json" | jq -c '[.[] | . + {
    _has_time: (if .due.datetime != null then 0 else 1 end),
    _time: (if .due.datetime != null then .due.datetime else "9999-12-31T23:59:59Z" end),
    _prio: (-((.priority // 1)))
  }] | sort_by(._has_time, ._time, ._prio, .createdAt)' 2>/dev/null
}

_trim_text() {
  local text="$1" max="$2"
  [ -z "$text" ] && return 0
  printf '%s' "$text" | awk -v n="$max" '{ print substr($0, 1, n) }'
}

_popup_is_visible() {
  sketchybar --query "$TODOIST_ITEM" 2>/dev/null | jq -r '.popup.drawing // "off"' 2>/dev/null
}

_hide_popup() {
  sketchybar --set "$TODOIST_ITEM" popup.drawing=off 2>/dev/null || true
}

_prio_icon() {
  case "$1" in
    4) echo "🔴" ;;
    3) echo "🟠" ;;
    2) echo "🔵" ;;
    *) echo "  " ;;
  esac
}

_render_popup() {
  local accent_color="${SPACE_FOCUSED_BORDER_COLOR:-0xff7aa2f7}"
  local label_color="${LABEL_COLOR:-0xffc0caf5}"
  local dim_color="0x80${label_color:4}"
  local slot=1

  sketchybar --set "$TODOIST_ITEM.popup.$slot" drawing=on \
    label="Open Todoist" label.color="$accent_color"
  sketchybar --set "$TODOIST_ITEM.popup.$slot" \
    click_script="open 'https://app.todoist.com/app/today'; sketchybar --set $TODOIST_ITEM popup.drawing=off"
  slot=$((slot + 1))

  sketchybar --set "$TODOIST_ITEM.popup.$slot" drawing=on label="── Today ──" \
    label.color="$dim_color" click_script=""
  slot=$((slot + 1))

  local tasks_json count
  tasks_json=$(_todoist_all_tasks_json 2>/dev/null || echo '[]')
  count=$(printf '%s' "$tasks_json" | jq 'length' 2>/dev/null || echo 0)

  if [ "$count" -eq 0 ]; then
    sketchybar --set "$TODOIST_ITEM.popup.$slot" drawing=on \
      label="  All done 🎉" label.color="$dim_color" click_script=""
    slot=$((slot + 1))
  else
    local i=0 max_tasks=8
    while [ "$i" -lt "$count" ] && [ "$i" -lt "$max_tasks" ] && [ "$slot" -le "$TODOIST_POPUP_SLOTS" ]; do
      local entry content prio icon row
      entry=$(printf '%s' "$tasks_json" | jq -c ".[$i]" 2>/dev/null)
      content=$(printf '%s' "$entry" | jq -r '.content // ""' 2>/dev/null)
      prio=$(printf '%s' "$entry" | jq -r '.priority // 1' 2>/dev/null)
      icon=$(_prio_icon "$prio")
      row="$icon $(_trim_text "$content" 28)"

      sketchybar --set "$TODOIST_ITEM.popup.$slot" drawing=on \
        label="$row" label.color="$label_color" click_script=""
      slot=$((slot + 1))
      i=$((i + 1))
    done

    if [ "$count" -gt "$max_tasks" ]; then
      local remaining=$((count - max_tasks))
      sketchybar --set "$TODOIST_ITEM.popup.$slot" drawing=on \
        label="  +${remaining} more" label.color="$dim_color" click_script=""
      slot=$((slot + 1))
    fi
  fi

  while [ "$slot" -le "$TODOIST_POPUP_SLOTS" ]; do
    sketchybar --set "$TODOIST_ITEM.popup.$slot" drawing=off
    slot=$((slot + 1))
  done
}

_toggle_popup() {
  if [ "$(_popup_is_visible)" = "on" ]; then
    _hide_popup
    return 0
  fi
  _render_popup
  sketchybar --set "$TODOIST_ITEM" popup.drawing=on
}

if [ "$SENDER" = "mouse.clicked" ]; then
  _toggle_popup
  exit 0
elif [ "$SENDER" = "space_change" ] || [ "$SENDER" = "front_app_switched" ]; then
  _hide_popup
fi

title=$(printf '%s' "$(_todoist_all_tasks_json 2>/dev/null || echo '[]')" | jq -r '.[0].content // empty' 2>/dev/null)
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
  label="$title"
