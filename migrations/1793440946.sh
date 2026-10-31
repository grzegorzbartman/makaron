#!/bin/bash
# Migration: Layout profiles (laptop / desktop)
# Compiles makaron-screen-info (built-in display size in points, drives the
# auto profile) and drops the layout caches so the new profile is applied on
# the next apply_desktop_state.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Layout profiles (laptop / desktop)"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

if [ -x "$MAKARON_PATH/bin/makaron-screen-info" ] \
    && "$MAKARON_PATH/bin/makaron-screen-info" 2>/dev/null | grep -qE '^[0-9]+ [0-9]+ [0-9]+$'; then
    echo "  ✓ makaron-screen-info already current"
elif command -v swiftc >/dev/null 2>&1 && [ -f "$MAKARON_PATH/src/screen_info.swift" ]; then
    swiftc -O -o "$MAKARON_PATH/bin/makaron-screen-info" "$MAKARON_PATH/src/screen_info.swift" 2>/dev/null \
        && echo "  ✓ Compiled makaron-screen-info" \
        || echo "  ⚠️  Compile failed, swift -e fallback stays in use"
else
    echo "  ⚠️  swiftc not available, swift -e fallback stays in use"
fi

rm -f "/tmp/makaron_$(id -u)_screen_v1" "/tmp/makaron_$(id -u)_notch_v2" 2>/dev/null || true

echo "Migration completed successfully"
