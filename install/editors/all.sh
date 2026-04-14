#!/bin/bash
# DEPRECATED: No longer sourced. See install/packages.sh

# Editors - simple installs
install_cask "sublime-text" "Sublime Text"
install_cask "visual-studio-code" "Visual Studio Code"
install_cask "cursor" "Cursor"

# Neovim with LazyVim (has additional setup)
source "$MAKARON_PATH/install/editors/neovim_lazyvim.sh"

