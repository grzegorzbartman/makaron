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
source "$MAKARON_PATH/install/desktop/fonts.sh"
source "$MAKARON_PATH/install/desktop/makaron-bar.sh"

# Terminal
source "$MAKARON_PATH/install/terminal/timewarrior.sh"
source "$MAKARON_PATH/install/terminal/ghostty.sh"

