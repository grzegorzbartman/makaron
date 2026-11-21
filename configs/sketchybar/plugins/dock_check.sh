#!/bin/sh
# A Dock respawned by macOS can keep its space reserved although autohide is
# on, so tiled windows stop short of the bottom edge. makaron-dock heal
# re-toggles autohide; a heal that does not clear it waits for the next Dock pid.

BIN="${MAKARON_PATH:-$HOME/.local/share/makaron}/bin/makaron-dock"
[ -x "$BIN" ] || exit 0
STATE_FILE="/tmp/makaron_$(id -u)_dock_stuck"
PID=$(pgrep -x Dock)
[ -n "$PID" ] && [ "$(cat "$STATE_FILE" 2>/dev/null)" = "$PID" ] && exit 0
"$BIN" heal >/dev/null 2>&1 || echo "$PID" > "$STATE_FILE"
