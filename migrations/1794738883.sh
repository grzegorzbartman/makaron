#!/bin/bash
# Migration: Remove the laptop tiles guard
# The auto-accordion above AEROSPACE_LAPTOP_MAX_TILES tiles is gone. Drops the
# variable from makaron.conf, returns workspaces the guard flipped to tiles and
# clears its per-workspace state.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Remove the laptop tiles guard"
MAKARON_CONF="${MAKARON_CONF:-$HOME/.config/makaron/makaron.conf}"

if [ -f "$MAKARON_CONF" ] && grep -q '^AEROSPACE_LAPTOP_MAX_TILES=' "$MAKARON_CONF"; then
    sed -i '' '/^AEROSPACE_LAPTOP_MAX_TILES=/d' "$MAKARON_CONF"
    echo "  ✓ AEROSPACE_LAPTOP_MAX_TILES removed"
fi

for state in /tmp/makaron-"$(id -u)"-tiles-guard-*; do
    [ -f "$state" ] || continue
    ws="${state##*-tiles-guard-}"
    if [ "$(cat "$state" 2>/dev/null)" = auto ] && command -v aerospace >/dev/null 2>&1; then
        aerospace layout --workspace "$ws" --root h_tiles 2>/dev/null || true
    fi
    rm -f "$state"
done

echo "Migration completed successfully"
