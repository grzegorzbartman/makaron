#!/bin/bash
# Open a new Ghostty window on the current workspace.
# Uses Ghostty's native AppleScript API (1.3+) - reliable from AeroSpace's
# exec-and-forget context, unlike System Events keystrokes which macOS
# Automation policy blocks sporadically (AeroSpace discussion #1147).
# Cold start: plain open, no -n (a second instance would duplicate the
# restored session).

CUR_WS=$(aerospace list-workspaces --focused 2>/dev/null)

if pgrep -xq ghostty; then
    osascript -e 'tell application "Ghostty" to new window' \
              -e 'tell application "Ghostty" to activate' >/dev/null 2>&1
else
    open -a Ghostty
    exit 0
fi

# Safety net: if focus jumped to another workspace with the new window,
# bring the window back to where the user was.
sleep 0.3
NEW_WS=$(aerospace list-workspaces --focused 2>/dev/null)
if [ -n "$CUR_WS" ] && [ "$NEW_WS" != "$CUR_WS" ]; then
    aerospace move-node-to-workspace --focus-follows-window "$CUR_WS" 2>/dev/null || true
fi
