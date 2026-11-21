#!/bin/bash
# Migration: Compile the Dock autohide helper
# makaron-dock re-toggles Dock autohide through CoreDock (no Automation
# permission) when a respawned Dock keeps its space reserved; plugins/dock_check.sh
# polls it and _restart_dock prefers it over System Events.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Compile the Dock autohide helper"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

if [ -x "$MAKARON_PATH/bin/makaron-dock" ] \
    && "$MAKARON_PATH/bin/makaron-dock" status 2>/dev/null | grep -qE '^autohide=[01] reserve=[0-9]+$'; then
    echo "  ✓ makaron-dock already current"
elif command -v swiftc >/dev/null 2>&1 && [ -f "$MAKARON_PATH/src/dock.swift" ]; then
    swiftc -O -o "$MAKARON_PATH/bin/makaron-dock" "$MAKARON_PATH/src/dock.swift" 2>/dev/null \
        && echo "  ✓ Compiled makaron-dock" \
        || echo "  ⚠️  Compile failed, Dock autohide keeps the System Events fallback"
else
    echo "  ⚠️  swiftc not available, Dock autohide keeps the System Events fallback"
fi

echo "Migration completed successfully"
