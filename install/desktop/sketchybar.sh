#!/bin/bash

# Install SketchyBar
if ! command -v sketchybar &> /dev/null; then
    brew tap FelixKratz/formulae
    brew install sketchybar
fi

# Setup SketchyBar config
if [ ! -L "$HOME/.config/sketchybar" ] && [ ! -d "$HOME/.config/sketchybar" ]; then
    ln -s "$MAKARON_PATH/configs/sketchybar" "$HOME/.config/sketchybar"
else
    # Check if symlink points to wrong location
    if [ -L "$HOME/.config/sketchybar" ]; then
        current_target=$(readlink "$HOME/.config/sketchybar")
        if [[ "$current_target" != "$MAKARON_PATH/configs/sketchybar" ]]; then
            echo "Fixing SketchyBar symlink to point to new location..."
            rm "$HOME/.config/sketchybar"
            ln -s "$MAKARON_PATH/configs/sketchybar" "$HOME/.config/sketchybar"
        fi
    else
        read -p "SketchyBar config exists. Overwrite? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$HOME/.config/sketchybar"
            ln -s "$MAKARON_PATH/configs/sketchybar" "$HOME/.config/sketchybar"
        fi
    fi
fi
