#!/bin/bash
# Migration: Compile memory_stats Swift binary
# Required after moving binary from git to compiled during install

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Compile memory_stats Swift binary"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

# Check if already compiled
if [ -x "$MAKARON_PATH/bin/makaron-memory-stats" ]; then
    echo "Already compiled, skipping"
    exit 0
fi

# Compile
if [ -f "$MAKARON_PATH/src/memory_stats.swift" ]; then
    echo "Compiling memory_stats.swift..."
    swiftc -O -o "$MAKARON_PATH/bin/makaron-memory-stats" "$MAKARON_PATH/src/memory_stats.swift"
    echo "Migration completed successfully"
else
    echo "Source file not found, skipping"
    exit 0
fi
