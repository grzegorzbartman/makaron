#!/bin/bash
# Migration: Uninstall AltTab
# AltTab removed from makaron — uninstall if present

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Uninstall AltTab"

if [ -d "/Applications/AltTab.app" ]; then
    echo "Uninstalling AltTab..."
    brew uninstall --cask alt-tab 2>/dev/null || true
    [ -d "/Applications/AltTab.app" ] && rm -rf "/Applications/AltTab.app"
    echo "AltTab uninstalled"
else
    echo "AltTab not installed, skipping"
fi

echo "Migration completed successfully"
