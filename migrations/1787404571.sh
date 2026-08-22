#!/bin/bash
# Migration: Compile notch detection binary
# Existing installs compile bin/makaron-has-notch (new installs get it via
# install/desktop/sketchybar.sh). Fallback to `swift -e` keeps working
# without it, just ~1s slower on cache misses.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Compile notch detection binary"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

if [ -x "$MAKARON_PATH/bin/makaron-has-notch" ]; then
    echo "  ✓ Already compiled"
elif command -v swiftc >/dev/null 2>&1 && [ -f "$MAKARON_PATH/src/has_notch.swift" ]; then
    swiftc -O -o "$MAKARON_PATH/bin/makaron-has-notch" "$MAKARON_PATH/src/has_notch.swift" 2>/dev/null \
        && echo "  ✓ Compiled makaron-has-notch" \
        || echo "  ⚠️  Compile failed, swift -e fallback stays in use"
else
    echo "  ⚠️  swiftc not available, swift -e fallback stays in use"
fi

echo "Migration completed successfully"
