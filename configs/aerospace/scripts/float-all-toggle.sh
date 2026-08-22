#!/bin/bash
# Toggle float/tile for all windows on the focused workspace.
# Floating windows are auto-arranged: FLOAT_ALL_LAYOUT=cascade|grid (makaron.conf).
# Positions are applied in ONE batched osascript call (no focus stealing).
# State file lists the floated window ids; stale after windows close/reopen.

MAKARON_CONF="$HOME/.config/makaron/makaron.conf"
FLOAT_ALL_LAYOUT=cascade
AEROSPACE_GAP_SIZE=12
SKETCHYBAR_HEIGHT=40
# shellcheck disable=SC1090
[ -f "$MAKARON_CONF" ] && source "$MAKARON_CONF"
case "$FLOAT_ALL_LAYOUT" in cascade|grid) ;; *) FLOAT_ALL_LAYOUT=cascade ;; esac
[[ "$AEROSPACE_GAP_SIZE" =~ ^[0-9]+$ ]] || AEROSPACE_GAP_SIZE=12
[[ "$SKETCHYBAR_HEIGHT" =~ ^[0-9]+$ ]] || SKETCHYBAR_HEIGHT=40

WS=$(aerospace list-workspaces --focused 2>/dev/null)
[ -z "$WS" ] && exit 0

WINDOWS=$(aerospace list-windows --workspace focused --format '%{window-id}|%{app-name}|%{window-title}' 2>/dev/null)
[ -z "$WINDOWS" ] && exit 0

STATE_FILE="/tmp/makaron-$(id -u)-float-all-ws-$WS"

if [ -f "$STATE_FILE" ]; then
    while read -r id; do
        [ -n "$id" ] && aerospace layout --window-id "$id" tiling 2>/dev/null
    done < "$STATE_FILE"
    rm -f "$STATE_FILE"
    exit 0
fi

: > "$STATE_FILE"
while IFS='|' read -r id _ _; do
    aerospace layout --window-id "$id" floating 2>/dev/null
    echo "$id" >> "$STATE_FILE"
done <<< "$WINDOWS"

sleep 0.1

# Focused monitor visible frame (top-left coords). visibleFrame already
# excludes the macOS menu bar, but not SketchyBar.
MON_ID=$(aerospace list-monitors --focused --format '%{monitor-appkit-nsscreen-screens-id}' 2>/dev/null)
GEOM=$(osascript -l JavaScript -e "
ObjC.import('AppKit');
const screens = \$.NSScreen.screens;
let idx = ${MON_ID:-1} - 1;
if (idx < 0 || idx >= screens.count) idx = 0;
const s = screens.objectAtIndex(idx);
const f = s.visibleFrame;
const m = screens.objectAtIndex(0).frame;
[Math.round(f.origin.x), Math.round(m.size.height - (f.origin.y + f.size.height)),
 Math.round(f.size.width), Math.round(f.size.height)].join(' ');
" 2>/dev/null)
[ -z "$GEOM" ] && exit 0
read -r MON_X MON_Y MON_W MON_H <<< "$GEOM"

if pgrep -x sketchybar >/dev/null 2>&1; then
    BAR=$((SKETCHYBAR_HEIGHT + AEROSPACE_GAP_SIZE))
    MON_Y=$((MON_Y + BAR))
    MON_H=$((MON_H - BAR))
fi

N=$(echo "$WINDOWS" | wc -l | tr -d ' ')
XS=() YS=() WWS=() WHS=()

if [ "$FLOAT_ALL_LAYOUT" = "grid" ]; then
    GAP=$((AEROSPACE_GAP_SIZE * 2))
    [ "$GAP" -lt 24 ] && GAP=24
    COLS=1
    while [ $((COLS * COLS)) -lt "$N" ]; do COLS=$((COLS + 1)); done
    ROWS=$(((N + COLS - 1) / COLS))
    CELL_W=$(((MON_W - GAP * (COLS + 1)) / COLS))
    CELL_H=$(((MON_H - GAP * (ROWS + 1)) / ROWS))
    i=0
    while [ "$i" -lt "$N" ]; do
        r=$((i / COLS)); c=$((i % COLS))
        in_row=$COLS
        [ "$r" -eq $((ROWS - 1)) ] && in_row=$((N - r * COLS))
        row_w=$((in_row * CELL_W + (in_row + 1) * GAP))
        off=$(((MON_W - row_w) / 2))
        XS+=($((MON_X + off + GAP + c * (CELL_W + GAP))))
        YS+=($((MON_Y + GAP + r * (CELL_H + GAP))))
        WWS+=("$CELL_W"); WHS+=("$CELL_H")
        i=$((i + 1))
    done
else
    WIN_W=$((MON_W * 70 / 100))
    WIN_H=$((MON_H * 70 / 100))
    MAX_OFF_X=$((MON_W - WIN_W - 100)); MAX_OFF_Y=$((MON_H - WIN_H - 100))
    MAX_OFF=$MAX_OFF_X
    [ "$MAX_OFF_Y" -lt "$MAX_OFF" ] && MAX_OFF=$MAX_OFF_Y
    STEP=0
    [ "$N" -gt 1 ] && STEP=$((MAX_OFF / (N - 1)))
    [ "$STEP" -gt 40 ] && STEP=40
    [ "$STEP" -lt 0 ] && STEP=0
    i=0
    while [ "$i" -lt "$N" ]; do
        XS+=($((MON_X + 50 + STEP * i)))
        YS+=($((MON_Y + 50 + STEP * i)))
        WWS+=("$WIN_W"); WHS+=("$WIN_H")
        i=$((i + 1))
    done
fi

esc() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }

# One AppleScript for all windows: match by title, fall back to the Nth
# window of the app (System Events order may differ from aerospace order
# for same-titled windows - acceptable).
SCRIPT="tell application \"System Events\""$'\n'
SEEN_APPS=""
i=0
while IFS='|' read -r _ app title; do
    a=$(esc "$app"); t=$(esc "$title")
    occ=$(($(printf '%s\n' "$SEEN_APPS" | grep -cxF -- "$app") + 1))
    SEEN_APPS="$SEEN_APPS"$'\n'"$app"
    SCRIPT+="try
tell process \"$a\"
set _w to missing value
if \"$t\" is not \"\" and (exists window \"$t\") then
set _w to window \"$t\"
else if (count of windows) >= $occ then
set _w to window $occ
end if
if _w is not missing value then
set position of _w to {${XS[$i]}, ${YS[$i]}}
set size of _w to {${WWS[$i]}, ${WHS[$i]}}
end if
end tell
end try
"
    i=$((i + 1))
done <<< "$WINDOWS"
SCRIPT+="end tell"

osascript -e "$SCRIPT" >/dev/null 2>&1
