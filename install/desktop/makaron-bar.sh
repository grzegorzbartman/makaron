#!/bin/bash

echo "Compiling MakaronBar..."
swiftc -O -o "$MAKARON_PATH/bin/makaron-bar" \
  "$MAKARON_PATH"/src/makaron_bar/*.swift \
  -framework AppKit -framework Carbon 2>/dev/null || {
    echo "Warning: Failed to compile MakaronBar"
}

if [ -f "$MAKARON_PATH/src/memory_stats.swift" ]; then
    echo "Compiling memory_stats..."
    swiftc -O -o "$MAKARON_PATH/bin/makaron-memory-stats" "$MAKARON_PATH/src/memory_stats.swift" 2>/dev/null || {
        echo "Warning: Failed to compile memory_stats.swift"
    }
fi


if [ -f "$MAKARON_PATH/src/calendar_next_event.swift" ]; then
    echo "Compiling calendar_next_event..."
    swiftc -O -o "$MAKARON_PATH/bin/makaron-calendar-next" "$MAKARON_PATH/src/calendar_next_event.swift" -framework EventKit 2>/dev/null || {
        echo "Warning: Failed to compile calendar_next_event.swift"
    }
fi
