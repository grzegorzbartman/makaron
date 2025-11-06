#!/bin/bash

# Migration: Install fzf
# Adds installation script for fzf tool for existing users

set -e

error_exit() {
  echo -e "\033[31mERROR: Migration failed! Manual intervention required.\033[0m" >&2
  exit 1
}

trap error_exit ERR

echo "Running migration: Install fzf"

# Set MAKARON_PATH if not already set
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

# Install fzf
if [ -f "$MAKARON_PATH/install/tools/fzf.sh" ]; then
    echo "Installing fzf..."
    source "$MAKARON_PATH/install/tools/fzf.sh"
else
    echo "fzf installation script not found, skipping"
fi

# Individual installation scripts check if applications are already installed (idempotent)
echo "Migration completed successfully"

