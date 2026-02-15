#!/bin/bash

# Development tools - simple installs
install_formula "composer" "Composer" "composer"
install_formula "ddev/ddev/ddev" "DDEV" "ddev"
install_formula "gh" "GitHub CLI" "gh"
install_formula "lazydocker" "lazydocker" "lazydocker"
install_formula "lazygit" "lazygit" "lazygit"
install_formula "node" "Node.js" "node"
install_formula "yarn" "Yarn" "yarn"
install_formula "platformsh/tap/upsun-cli" "Upsun CLI" "upsun"
install_cask "bruno" "Bruno"
install_cask "docker-desktop" "Docker"
install_cask "sequel-ace" "Sequel Ace"

# Tools with additional setup
source "$MAKARON_PATH/install/development/pipx.sh"
