#!/bin/bash
# Migration: Trust the Borders Homebrew formula
# Homebrew >= 6.0 requires explicit trust before loading third-party services.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Trust the Borders Homebrew formula"

if ! brew trust --json=v1 &>/dev/null; then
    echo "Homebrew formula trust not supported, skipping"
    exit 0
fi

brew trust --formula felixkratz/formulae/borders

echo "Migration completed successfully"
