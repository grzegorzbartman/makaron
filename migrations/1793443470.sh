#!/bin/bash
# Migration: Compile the audio output probe
# makaron-audio-out (CoreAudio) replaces osascript + system_profiler in the
# volume plugin, which ran the slow probe on every 10s refresh.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Compile the audio output probe"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

if [ -x "$MAKARON_PATH/bin/makaron-audio-out" ] \
    && "$MAKARON_PATH/bin/makaron-audio-out" 2>/dev/null | grep -qE '^(bluetooth|other) '; then
    echo "  ✓ makaron-audio-out already current"
elif command -v swiftc >/dev/null 2>&1 && [ -f "$MAKARON_PATH/src/audio_out.swift" ]; then
    swiftc -O -o "$MAKARON_PATH/bin/makaron-audio-out" "$MAKARON_PATH/src/audio_out.swift" 2>/dev/null \
        && echo "  ✓ Compiled makaron-audio-out" \
        || echo "  ⚠️  Compile failed, volume keeps the system_profiler fallback"
else
    echo "  ⚠️  swiftc not available, volume keeps the system_profiler fallback"
fi

rm -f "/tmp/sketchybar_$(id -u)_audio_device" 2>/dev/null || true

echo "Migration completed successfully"
