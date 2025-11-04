#!/bin/bash

# Migration: Install new development tools, system tools, and UI applications
# Adds installation scripts for node/yarn, pipx, rbenv, neovim, tmux, btop,
# platformsh-cli, dozer, codex, sublime-text, chatgpt for existing users

set -e

error_exit() {
  echo -e "\033[31mERROR: Migration failed! Manual intervention required.\033[0m" >&2
  exit 1
}

trap error_exit ERR

echo "Running migration: Install new development tools, system tools, and UI applications"

# Set MAKARON_PATH if not already set
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

# Install development tools
if [ -f "$MAKARON_PATH/install/development/node.sh" ]; then
    echo "Installing Node.js and Yarn..."
    source "$MAKARON_PATH/install/development/node.sh"
else
    echo "Node.js installation script not found, skipping"
fi

if [ -f "$MAKARON_PATH/install/development/pipx.sh" ]; then
    echo "Installing pipx..."
    source "$MAKARON_PATH/install/development/pipx.sh"
else
    echo "pipx installation script not found, skipping"
fi

if [ -f "$MAKARON_PATH/install/development/rbenv.sh" ]; then
    echo "Installing rbenv..."
    source "$MAKARON_PATH/install/development/rbenv.sh"
else
    echo "rbenv installation script not found, skipping"
fi

# Install system tools
if [ -f "$MAKARON_PATH/install/tools/neovim.sh" ]; then
    echo "Installing Neovim..."
    source "$MAKARON_PATH/install/tools/neovim.sh"
else
    echo "Neovim installation script not found, skipping"
fi

if [ -f "$MAKARON_PATH/install/tools/tmux.sh" ]; then
    echo "Installing tmux..."
    source "$MAKARON_PATH/install/tools/tmux.sh"
else
    echo "tmux installation script not found, skipping"
fi

if [ -f "$MAKARON_PATH/install/tools/btop.sh" ]; then
    echo "Installing btop..."
    source "$MAKARON_PATH/install/tools/btop.sh"
else
    echo "btop installation script not found, skipping"
fi

if [ -f "$MAKARON_PATH/install/tools/platformsh-cli.sh" ]; then
    echo "Installing Platform.sh CLI..."
    source "$MAKARON_PATH/install/tools/platformsh-cli.sh"
else
    echo "Platform.sh CLI installation script not found, skipping"
fi

# Install UI applications
if [ -f "$MAKARON_PATH/install/ui/dozer.sh" ]; then
    echo "Installing Dozer..."
    source "$MAKARON_PATH/install/ui/dozer.sh"
else
    echo "Dozer installation script not found, skipping"
fi

if [ -f "$MAKARON_PATH/install/ui/codex.sh" ]; then
    echo "Installing Codex..."
    source "$MAKARON_PATH/install/ui/codex.sh"
else
    echo "Codex installation script not found, skipping"
fi

if [ -f "$MAKARON_PATH/install/ui/sublime-text.sh" ]; then
    echo "Installing Sublime Text..."
    source "$MAKARON_PATH/install/ui/sublime-text.sh"
else
    echo "Sublime Text installation script not found, skipping"
fi

if [ -f "$MAKARON_PATH/install/ui/chatgpt.sh" ]; then
    echo "Installing ChatGPT..."
    source "$MAKARON_PATH/install/ui/chatgpt.sh"
else
    echo "ChatGPT installation script not found, skipping"
fi

# Individual installation scripts check if applications are already installed (idempotent)
echo "Migration completed successfully"


