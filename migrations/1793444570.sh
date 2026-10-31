#!/bin/bash
# Migration: Compile the CPU stats probe
# makaron-cpu-stats (Mach tick deltas) replaces the ps-based CPU percent,
# which reported decayed per-process averages instead of current load.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Compile the CPU stats probe"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

if [ -x "$MAKARON_PATH/bin/makaron-cpu-stats" ] \
    && "$MAKARON_PATH/bin/makaron-cpu-stats" 2>/dev/null | grep -qE '^[0-9]+$'; then
    echo "  ✓ makaron-cpu-stats already current"
elif command -v swiftc >/dev/null 2>&1 && [ -f "$MAKARON_PATH/src/cpu_stats.swift" ]; then
    swiftc -O -o "$MAKARON_PATH/bin/makaron-cpu-stats" "$MAKARON_PATH/src/cpu_stats.swift" 2>/dev/null \
        && echo "  ✓ Compiled makaron-cpu-stats" \
        || echo "  ⚠️  Compile failed, CPU keeps the ps fallback"
else
    echo "  ⚠️  swiftc not available, CPU keeps the ps fallback"
fi

echo "Migration completed successfully"
