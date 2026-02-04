#!/bin/bash

# Desktop tools
install_cask "alt-tab" "AltTab"
install_cask "command-x" "Command X"
install_cask "stats" "Stats"

# Components with additional config
source "$MAKARON_PATH/install/desktop/aerospace.sh"
source "$MAKARON_PATH/install/desktop/borders.sh"
source "$MAKARON_PATH/install/desktop/fonts.sh"
source "$MAKARON_PATH/install/desktop/sketchybar.sh"

# Initialize default theme (tokyo-night)
echo "Setting up default theme (Tokyo Night)..."
if [ ! -L "$MAKARON_PATH/current-theme" ]; then
    ln -s "$MAKARON_PATH/themes/tokyo-night" "$MAKARON_PATH/current-theme"
    echo "Default theme set to Tokyo Night"
fi
