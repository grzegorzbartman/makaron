#!/bin/bash
# Migration: Compile the menu bar autohide setter
# makaron-menubar switches menu bar autohide via prefs + notifications,
# replacing the System Settings UI click (kept as fallback) in makaron-ui-full/stop.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Compile the menu bar autohide setter"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

if [ -x "$MAKARON_PATH/bin/makaron-menubar" ] \
    && "$MAKARON_PATH/bin/makaron-menubar" status 2>/dev/null | grep -qE '^(always|desktop|fullscreen|never)$'; then
    echo "  ✓ makaron-menubar already current"
elif command -v swiftc >/dev/null 2>&1 && [ -f "$MAKARON_PATH/src/menubar.swift" ]; then
    swiftc -O -o "$MAKARON_PATH/bin/makaron-menubar" "$MAKARON_PATH/src/menubar.swift" 2>/dev/null \
        && echo "  ✓ Compiled makaron-menubar" \
        || echo "  ⚠️  Compile failed, menu bar keeps the System Settings UI fallback"
else
    echo "  ⚠️  swiftc not available, menu bar keeps the System Settings UI fallback"
fi

echo "Migration completed successfully"
