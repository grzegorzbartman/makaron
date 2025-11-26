#!/bin/bash
# Migration: Setup Brew Autoupdate
# Configures automatic Homebrew updates every 24h with upgrade and cleanup

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Setup Brew Autoupdate"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

if ! command -v brew &>/dev/null; then
    echo "Brew not installed, skipping"
    exit 0
fi

# Check if already running
if brew autoupdate status 2>/dev/null | grep -q "installed and running"; then
    echo "Brew autoupdate already configured, skipping"
    exit 0
fi

# Add tap if not present
if ! brew tap | grep -q "domt4/autoupdate"; then
    if ! brew tap domt4/autoupdate 2>/dev/null; then
        echo "Failed to add tap (network issue?), skipping"
        exit 0
    fi
fi

# Start autoupdate with upgrade and cleanup (24h interval)
if ! brew autoupdate start --upgrade --cleanup 2>/dev/null; then
    echo "Failed to start autoupdate, skipping"
    exit 0
fi

echo "Migration completed successfully"
echo "Brew will auto-update every 24h with upgrade & cleanup"

