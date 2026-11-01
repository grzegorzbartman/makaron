#!/bin/bash
# Migration: Restart a Dock left dead by killall
# killall Dock can exit 0 and launchd never respawns it, so the Dock stops showing.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Restart a Dock left dead by killall"

if pgrep -x Dock >/dev/null; then
    echo "  ✓ Dock is running, nothing to do"
    exit 0
fi

launchctl kickstart "gui/$(id -u)/com.apple.Dock.agent" 2>/dev/null || true
echo "  ✓ Dock restarted"

echo "Migration completed successfully"
