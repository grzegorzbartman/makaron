#!/bin/bash

# Migration: Install Flameshot
# Adds installation script for Flameshot tool for existing users

set -e

error_exit() {
  echo -e "\033[31mERROR: Migration failed! Manual intervention required.\033[0m" >&2
  exit 1
}

trap error_exit ERR

echo "Running migration: Install Flameshot"

# Set MAKARON_PATH if not already set
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

# Install Flameshot
if [ -f "$MAKARON_PATH/install/tools/flameshot.sh" ]; then
    echo "Installing Flameshot..."
    source "$MAKARON_PATH/install/tools/flameshot.sh"
else
    echo "Flameshot installation script not found, skipping"
fi

# Individual installation scripts check if applications are already installed (idempotent)
echo "Migration completed successfully"

