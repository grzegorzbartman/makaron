#!/bin/bash

# Install Ghostty
install_cask "ghostty" "Ghostty"

# Setup Ghostty config
mkdir -p "$HOME/.config"
if [ ! -L "$HOME/.config/ghostty" ] && [ ! -d "$HOME/.config/ghostty" ]; then
    ln -s "$MAKARON_PATH/configs/ghostty" "$HOME/.config/ghostty"
else
    if [ -L "$HOME/.config/ghostty" ]; then
        current_target=$(readlink "$HOME/.config/ghostty")
        if [[ "$current_target" != "$MAKARON_PATH/configs/ghostty" ]]; then
            echo "Fixing Ghostty symlink to point to new location..."
            rm "$HOME/.config/ghostty"
            ln -s "$MAKARON_PATH/configs/ghostty" "$HOME/.config/ghostty"
        fi
    else
        read -p "Ghostty config exists. Overwrite? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$HOME/.config/ghostty"
            ln -s "$MAKARON_PATH/configs/ghostty" "$HOME/.config/ghostty"
        fi
    fi
fi

# Protect config from git reset during updates
if [ -d "$MAKARON_PATH/.git" ] && [ -f "$MAKARON_PATH/configs/ghostty/config" ]; then
    cd "$MAKARON_PATH"
    git update-index --skip-worktree "configs/ghostty/config" 2>/dev/null || true
fi
