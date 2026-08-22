#!/bin/bash
# Open a new Ghostty window without duplicating session state.
# Running instance: Cmd-N via System Events (AeroSpace's accessibility
# permission covers this). Cold start: plain open, no -n - a new instance
# would restore the saved session AND open a window, producing duplicates.

if pgrep -xq ghostty; then
    osascript -e 'tell application "Ghostty" to activate' \
              -e 'tell application "System Events" to keystroke "n" using command down'
else
    open -a Ghostty
fi
