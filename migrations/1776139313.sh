#!/bin/bash
# Migration: Enable Notes quick action
# Sets MAKARON_NOTES_ENABLED=true and renames old SKETCHYBAR_NOTES_ENABLED

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Enable Notes quick action"
MAKARON_CONF="${MAKARON_CONF:-$HOME/.config/makaron/makaron.conf}"

if [ ! -f "$MAKARON_CONF" ]; then
    echo "Config not found, skipping"
    exit 0
fi

# Rename old variable if present
if grep -q '^SKETCHYBAR_NOTES_ENABLED=' "$MAKARON_CONF" 2>/dev/null; then
    sed -i '' 's/^SKETCHYBAR_NOTES_ENABLED=/MAKARON_NOTES_ENABLED=/' "$MAKARON_CONF"
fi

if grep -q '^MAKARON_NOTES_ENABLED=true' "$MAKARON_CONF" 2>/dev/null; then
    echo "Already enabled, skipping"
    exit 0
fi

if grep -q '^MAKARON_NOTES_ENABLED=' "$MAKARON_CONF" 2>/dev/null; then
    sed -i '' 's/^MAKARON_NOTES_ENABLED=.*/MAKARON_NOTES_ENABLED=true/' "$MAKARON_CONF"
else
    echo "" >> "$MAKARON_CONF"
    echo "MAKARON_NOTES_ENABLED=true" >> "$MAKARON_CONF"
fi

echo "Migration completed successfully"
