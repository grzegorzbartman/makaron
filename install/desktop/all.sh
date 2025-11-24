#!/bin/bash

# Source all desktop environment installation scripts
source "$MAKARON_PATH/install/desktop/aerospace.sh"
source "$MAKARON_PATH/install/desktop/alt-tab.sh"
source "$MAKARON_PATH/install/desktop/borders.sh"
source "$MAKARON_PATH/install/desktop/command-x.sh"
source "$MAKARON_PATH/install/desktop/dozer.sh"
source "$MAKARON_PATH/install/desktop/fonts.sh"
source "$MAKARON_PATH/install/desktop/sketchybar.sh"
source "$MAKARON_PATH/install/desktop/stats.sh"

# Initialize default theme (tokyo-night)
echo "Setting up default theme (Tokyo Night)..."
if [ ! -L "$MAKARON_PATH/current-theme" ]; then
    ln -s "$MAKARON_PATH/themes/tokyo-night" "$MAKARON_PATH/current-theme"
    echo "Default theme set to Tokyo Night"
fi
