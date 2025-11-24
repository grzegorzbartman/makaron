#!/bin/bash

# Install AeroSpace
if ! command -v aerospace &> /dev/null; then
    brew install --cask nikitabobko/tap/aerospace
fi

# Setup AeroSpace config
if [ ! -L "$HOME/.aerospace.toml" ] && [ ! -f "$HOME/.aerospace.toml" ]; then
    ln -s "$MAKARON_PATH/configs/aerospace/.aerospace.toml" "$HOME/.aerospace.toml"
else
    # Check if symlink points to wrong location
    if [ -L "$HOME/.aerospace.toml" ]; then
        current_target=$(readlink "$HOME/.aerospace.toml")
        if [[ "$current_target" != "$MAKARON_PATH/configs/aerospace/.aerospace.toml" ]]; then
            echo "Fixing AeroSpace symlink to point to new location..."
            rm "$HOME/.aerospace.toml"
            ln -s "$MAKARON_PATH/configs/aerospace/.aerospace.toml" "$HOME/.aerospace.toml"
        fi
    else
        read -p "AeroSpace config exists. Overwrite? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -f "$HOME/.aerospace.toml"
            ln -s "$MAKARON_PATH/configs/aerospace/.aerospace.toml" "$HOME/.aerospace.toml"
        fi
    fi
fi
