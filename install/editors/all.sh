#!/bin/bash

# Editors - simple installs
install_cask "sublime-text" "Sublime Text"
install_cask "visual-studio-code" "Visual Studio Code"
install_cask "cursor" "Cursor"

# Neovim with LazyVim (has additional setup)
source "$MAKARON_PATH/install/editors/neovim_lazyvim.sh"

# Apply default editor profile to VSCode/Cursor
if [ -x "$MAKARON_PATH/bin/makaron-apply-editor-profile" ]; then
    echo -e "${BLUE}Applying editor profile...${NC}"
    "$MAKARON_PATH/bin/makaron-apply-editor-profile" development-php-drupal 2>/dev/null || true
fi
