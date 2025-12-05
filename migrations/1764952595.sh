#!/bin/bash
# Migration: Add Powerlevel10k
# Installs Powerlevel10k and sets up config symlink for existing users

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Add Powerlevel10k"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

# Source helpers for install_formula function
if [ -f "$MAKARON_PATH/install/helpers.sh" ]; then
    source "$MAKARON_PATH/install/helpers.sh"
else
    echo "Helpers not found, skipping"
    exit 0
fi

# Install powerlevel10k (theme package without CLI command)
BREW_PREFIX="$(brew --prefix)"
if brew list powerlevel10k &>/dev/null; then
    echo "Powerlevel10k already installed"
else
    echo "Installing Powerlevel10k..."
    brew install powerlevel10k || echo "Warning: Failed to install Powerlevel10k (continuing...)"
fi

# Setup p10k config symlink
P10K_CONFIG="$HOME/.p10k.zsh"
P10K_CONFIG_SRC="$MAKARON_PATH/configs/p10k/p10k.zsh"

if [ ! -f "$P10K_CONFIG_SRC" ]; then
    echo "p10k config not found in makaron, skipping symlink setup"
else
    if [ ! -L "$P10K_CONFIG" ] && [ ! -f "$P10K_CONFIG" ]; then
        ln -s "$P10K_CONFIG_SRC" "$P10K_CONFIG"
        echo "Created p10k config symlink"
    elif [ -L "$P10K_CONFIG" ]; then
        current_target=$(readlink "$P10K_CONFIG")
        if [[ "$current_target" != "$P10K_CONFIG_SRC" ]]; then
            echo "Fixing p10k symlink to point to makaron config..."
            rm "$P10K_CONFIG"
            ln -s "$P10K_CONFIG_SRC" "$P10K_CONFIG"
        else
            echo "p10k symlink already correct"
        fi
    else
        echo "Backing up existing p10k config to ~/.p10k.zsh.backup..."
        cp "$P10K_CONFIG" "$HOME/.p10k.zsh.backup"
        rm "$P10K_CONFIG"
        ln -s "$P10K_CONFIG_SRC" "$P10K_CONFIG"
    fi
fi

# Add p10k to .zshrc if not present
zshrc="$HOME/.zshrc"
touch "$zshrc" 2>/dev/null || true

# Instant prompt block
instant_prompt='# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi'

# Add instant prompt at top if not present
if ! grep -q "p10k-instant-prompt" "$zshrc" 2>/dev/null; then
    tmp=$(mktemp)
    echo "$instant_prompt" > "$tmp"
    echo "" >> "$tmp"
    cat "$zshrc" >> "$tmp"
    mv "$tmp" "$zshrc"
    echo "Added instant prompt to .zshrc"
fi

# Add theme source if not present
if ! grep -q "powerlevel10k.zsh-theme" "$zshrc" 2>/dev/null; then
    echo "" >> "$zshrc"
    echo "source $BREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme" >> "$zshrc"
    echo "Added theme source to .zshrc"
fi

# Add config source if not present
if ! grep -q "source ~/.p10k.zsh" "$zshrc" 2>/dev/null; then
    echo "" >> "$zshrc"
    echo "# To customize prompt, run \`p10k configure\` or edit ~/.p10k.zsh." >> "$zshrc"
    echo "[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh" >> "$zshrc"
    echo "Added config source to .zshrc"
fi

echo "Migration completed successfully"

