#!/bin/bash

# Terminal tools
install_formula "btop" "btop" "btop"
install_formula "ffmpeg" "ffmpeg" "ffmpeg"
install_formula "fzf" "fzf" "fzf"
install_formula "gum" "gum" "gum"
install_formula "htop" "htop" "htop"
install_formula "jq" "jq" "jq"
install_formula "tmux" "tmux" "tmux"
install_formula "tree" "tree" "tree"

# Ghostty (has additional config setup)
source "$MAKARON_PATH/install/terminal/ghostty.sh"
