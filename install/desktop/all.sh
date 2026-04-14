#!/bin/bash
# DEPRECATED: No longer sourced. Core desktop → install/mandatory.sh, extras → install/packages.sh

# Desktop tools
install_cask "command-x" "Command X"
install_cask "stats" "Stats"

# Components with additional config
source "$MAKARON_PATH/install/desktop/aerospace.sh"
source "$MAKARON_PATH/install/desktop/fonts.sh"
source "$MAKARON_PATH/install/desktop/makaron-bar.sh"

