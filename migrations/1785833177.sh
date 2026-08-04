#!/bin/bash
# Migration: Restore the AeroSpace CLI for manually installed app bundles
# The CLI is a separate cask artifact required by SketchyBar plugins.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Restore AeroSpace CLI"

if command -v aerospace &>/dev/null; then
    echo "AeroSpace CLI already installed"
    exit 0
fi

if [ ! -d "/Applications/AeroSpace.app" ]; then
    echo "AeroSpace app not found, skipping"
    exit 0
fi

if brew install --cask --adopt "nikitabobko/tap/aerospace" \
    && command -v aerospace &>/dev/null; then
    echo "AeroSpace CLI installed"
elif { brew reinstall --cask --force "nikitabobko/tap/aerospace" \
    || brew install --cask --force "nikitabobko/tap/aerospace"; } \
    && command -v aerospace &>/dev/null; then
    echo "AeroSpace reinstalled with CLI"
else
    echo "AeroSpace CLI is still unavailable" >&2
    exit 1
fi

echo "Migration completed successfully"
