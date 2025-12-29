#!/bin/bash

source "$MAKARON_PATH/install/helpers.sh"

# Install SketchyBar (CRITICAL component)
brew tap FelixKratz/formulae 2>/dev/null || true
install_formula_critical "sketchybar" "SketchyBar"

# Compile memory stats binary (uses Mach API for accurate Activity Monitor values)
if [ -f "$MAKARON_PATH/src/memory_stats.swift" ]; then
    echo "Compiling memory_stats..."
    swiftc -O -o "$MAKARON_PATH/bin/makaron-memory-stats" "$MAKARON_PATH/src/memory_stats.swift" 2>/dev/null || {
        echo "Warning: Failed to compile memory_stats.swift, memory display may be inaccurate"
    }
fi

# Setup SketchyBar config
mkdir -p "$HOME/.config"

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
        # Directory exists but is not a symlink - back it up and replace
        echo "Backing up existing SketchyBar config..."
        mv "$HOME/.config/sketchybar" "$HOME/.config/sketchybar.backup.$(date +%s)"
        ln -s "$MAKARON_PATH/configs/sketchybar" "$HOME/.config/sketchybar"
    fi
fi
