#!/bin/bash

# Editors - simple installs
install_cask "phpstorm" "PhpStorm"
install_cask "sublime-text" "Sublime Text"
install_cask "visual-studio-code" "Visual Studio Code"

# Neovim with LazyVim (has additional setup)
source "$MAKARON_PATH/install/editors/neovim_lazyvim.sh"
