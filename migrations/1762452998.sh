#!/bin/bash

# Migration: Install gum
# Adds installation script for gum tool for existing users

set -e

error_exit() {
  echo -e "\033[31mERROR: Migration failed! Manual intervention required.\033[0m" >&2
  exit 1
}

trap error_exit ERR

echo "Running migration: Install gum"

# Set MAKARON_PATH if not already set
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

# Install gum
if [ -f "$MAKARON_PATH/install/tools/gum.sh" ]; then
    echo "Installing gum..."
    source "$MAKARON_PATH/install/tools/gum.sh"
else
    echo "gum installation script not found, skipping"
fi

# Individual installation scripts check if applications are already installed (idempotent)
echo "Migration completed successfully"

