#!/usr/bin/env bash

# This script reloads SketchyBar when display configuration changes
# (monitor connected/disconnected)

# Get current monitor count
CURRENT_MONITOR_COUNT=$(aerospace list-monitors 2>/dev/null | wc -l | tr -d ' ')

# Store monitor count in a temp file
MONITOR_COUNT_FILE="/tmp/sketchybar_monitor_count"

# Read previous count
if [ -f "$MONITOR_COUNT_FILE" ]; then
  PREVIOUS_MONITOR_COUNT=$(cat "$MONITOR_COUNT_FILE")
else
  PREVIOUS_MONITOR_COUNT=0
fi

# Update stored count
echo "$CURRENT_MONITOR_COUNT" > "$MONITOR_COUNT_FILE"

# If monitor count changed, reload SketchyBar
if [ "$CURRENT_MONITOR_COUNT" != "$PREVIOUS_MONITOR_COUNT" ] && [ "$PREVIOUS_MONITOR_COUNT" != "0" ]; then
  # Delay reload slightly to let system stabilize
  sleep 0.5
  sketchybar --reload
fi

