#!/bin/bash

# Migration: Initialize theme system
# Sets up default Tokyo Night theme for existing installations

set -e

error_exit() {
  echo -e "\033[31mERROR: Migration failed! Manual intervention required.\033[0m" >&2
  exit 1
}

trap error_exit ERR

echo "Running migration: Initialize theme system"

MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

# Check if current-theme symlink already exists
if [ -L "$MAKARON_PATH/current-theme" ]; then
    echo "Theme system already initialized, skipping"
    exit 0
fi

# Create symlink to default theme (Tokyo Night)
if [ -d "$MAKARON_PATH/themes/tokyo-night" ]; then
    ln -s "$MAKARON_PATH/themes/tokyo-night" "$MAKARON_PATH/current-theme"
    echo "Default theme (Tokyo Night) initialized successfully"
else
    echo "Warning: Tokyo Night theme directory not found. Theme system will be set up on next update."
    exit 0
fi

# Start borders service if installed and not running
if command -v borders &> /dev/null; then
    if ! brew services list | grep -q "borders.*started"; then
        echo "Starting borders service..."
        brew services start borders
    fi
fi

echo "Migration completed successfully"

