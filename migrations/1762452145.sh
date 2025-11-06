#!/bin/bash

# Migration: Install Neovim with LazyVim
# Adds installation script for Neovim with LazyVim configuration for existing users

set -e

error_exit() {
  echo -e "\033[31mERROR: Migration failed! Manual intervention required.\033[0m" >&2
  exit 1
}

trap error_exit ERR

echo "Running migration: Install Neovim with LazyVim"

# Set MAKARON_PATH if not already set
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

# Install Neovim with LazyVim
if [ -f "$MAKARON_PATH/install/tools/neovim_lazyvim.sh" ]; then
    echo "Installing Neovim with LazyVim..."
    source "$MAKARON_PATH/install/tools/neovim_lazyvim.sh"
else
    echo "Neovim LazyVim installation script not found, skipping"
fi

# Individual installation scripts check if applications are already installed (idempotent)
echo "Migration completed successfully"

