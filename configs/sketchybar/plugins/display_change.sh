#!/usr/bin/env bash

RUNTIME_ID=$(id -u)

# Invalidate caches that depend on display topology.
rm -f "/tmp/makaron_${RUNTIME_ID}_screen_width" 2>/dev/null
rm -f "/tmp/makaron_${RUNTIME_ID}_notch_v2" 2>/dev/null
rm -f "/tmp/makaron_${RUNTIME_ID}_has_builtin_notch" 2>/dev/null  # legacy name

command -v aerospace >/dev/null 2>&1 || exit 0

# Get current monitor count
CURRENT_MONITOR_COUNT=$(aerospace list-monitors 2>/dev/null | wc -l | tr -d ' ')
case "$CURRENT_MONITOR_COUNT" in
  ''|0|*[!0-9]*) exit 0 ;;
esac

MONITOR_COUNT_FILE="/tmp/sketchybar_${RUNTIME_ID}_monitor_count"

if [ -f "$MONITOR_COUNT_FILE" ]; then
  PREVIOUS_MONITOR_COUNT=$(cat "$MONITOR_COUNT_FILE")
else
  PREVIOUS_MONITOR_COUNT=0
fi

printf '%s\n' "$CURRENT_MONITOR_COUNT" > "$MONITOR_COUNT_FILE" || exit 0

# Re-apply desktop state on every display change: notch presence can change even
# when monitor count stays the same (external-only ↔ built-in display).
if [ "$PREVIOUS_MONITOR_COUNT" != "0" ]; then
  sleep 0.5

  if [ "$CURRENT_MONITOR_COUNT" != "$PREVIOUS_MONITOR_COUNT" ]; then
    sketchybar --reload
  fi

  # Re-apply desktop state: outer.top depends on notch presence which may have
  # changed (clamshell open/close, dock attach/detach with notched MBP).
  MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
  UI_HELPERS="$MAKARON_PATH/bin/makaron-ui-helpers"
  if [ -f "$UI_HELPERS" ]; then
    # shellcheck source=/dev/null
    source "$UI_HELPERS"
    apply_desktop_state 2>/dev/null || true
  fi
fi
