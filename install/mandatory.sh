#!/bin/bash

# ═══════════════════════════════════════════════════════════════════
# MAKARON MANDATORY COMPONENTS
# Always installed — core desktop environment
# ═══════════════════════════════════════════════════════════════════

source "$MAKARON_PATH/install/helpers.sh"
source "$MAKARON_PATH/install/makaron-conf.sh"
source "$MAKARON_PATH/install/brew.sh"

# gum — required for package selection UI
install_formula "gum" "gum" "gum"

# jq — used by core scripts
install_formula "jq" "jq" "jq"

# Core desktop components
source "$MAKARON_PATH/install/desktop/aerospace.sh"
source "$MAKARON_PATH/install/desktop/borders.sh"
source "$MAKARON_PATH/install/desktop/fonts.sh"
source "$MAKARON_PATH/install/desktop/sketchybar.sh"

# Terminal
source "$MAKARON_PATH/install/terminal/ghostty.sh"

# Default theme
if [ ! -L "$MAKARON_PATH/current-theme" ]; then
    ln -s "$MAKARON_PATH/themes/tokyo-night" "$MAKARON_PATH/current-theme"
    echo "Default theme set to Tokyo Night"
fi
