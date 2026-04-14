#!/bin/bash
# Migration: Compile calendar_next_event Swift binary
# Required for MakaronBar calendar widget

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Compile calendar_next_event Swift binary"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

if [ -x "$MAKARON_PATH/bin/makaron-calendar-next" ]; then
    echo "Already compiled, skipping"
    exit 0
fi

if [ ! -f "$MAKARON_PATH/src/calendar_next_event.swift" ]; then
    echo "Source file missing, skipping"
    exit 0
fi

echo "Compiling calendar_next_event..."
swiftc -O -o "$MAKARON_PATH/bin/makaron-calendar-next" "$MAKARON_PATH/src/calendar_next_event.swift" -framework EventKit 2>/dev/null || {
    echo "Warning: Failed to compile calendar_next_event.swift; calendar widget will use icalBuddy fallback"
    exit 0
}

echo "Migration completed successfully"
