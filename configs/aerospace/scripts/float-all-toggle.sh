#!/bin/bash
# Toggle float/tile for all windows on focused workspace
# Float mode arranges windows in cascade layout

WS=$(aerospace list-workspaces --focused 2>/dev/null)
[ -z "$WS" ] && exit 0

IDS=$(aerospace list-windows --workspace focused --format '%{window-id}|%{app-name}' 2>/dev/null)
[ -z "$IDS" ] && exit 0

STATE_FILE="/tmp/makaron-float-all-ws-$WS"

if [ -f "$STATE_FILE" ]; then
    while IFS='|' read -r id app; do
        aerospace layout --window-id "$id" tiling
    done <<< "$IDS"
    rm -f "$STATE_FILE"
else
    while IFS='|' read -r id app; do
        aerospace layout --window-id "$id" floating
    done <<< "$IDS"

    sleep 0.1

    SCREEN_W=$(osascript -e 'tell application "Finder" to return item 3 of (get bounds of window of desktop)' 2>/dev/null)
    SCREEN_H=$(osascript -e 'tell application "Finder" to return item 4 of (get bounds of window of desktop)' 2>/dev/null)
    [ -z "$SCREEN_W" ] && { touch "$STATE_FILE"; exit 0; }

    WIN_COUNT=$(echo "$IDS" | wc -l | tr -d ' ')
    WIN_W=$((SCREEN_W * 70 / 100))
    WIN_H=$((SCREEN_H * 70 / 100))
    MAX_OFFSET=$(( (SCREEN_W - WIN_W) < (SCREEN_H - WIN_H) ? (SCREEN_W - WIN_W) : (SCREEN_H - WIN_H) ))
    STEP=$(( WIN_COUNT > 1 ? MAX_OFFSET / (WIN_COUNT - 1) : 0 ))
    [ "$STEP" -gt 40 ] && STEP=40
    START_X=50
    START_Y=50

    i=0
    while IFS='|' read -r id app; do
        X=$((START_X + STEP * i))
        Y=$((START_Y + STEP * i))
        aerospace focus --window-id "$id" 2>/dev/null
        osascript -e "tell application \"System Events\" to tell process \"$app\"
            try
                set position of front window to {$X, $Y}
                set size of front window to {$WIN_W, $WIN_H}
            end try
        end tell" 2>/dev/null
        i=$((i + 1))
    done <<< "$IDS"

    touch "$STATE_FILE"
fi
