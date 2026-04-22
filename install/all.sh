#!/bin/bash

# Mandatory components (always installed)
source "$MAKARON_PATH/install/mandatory.sh"

# Optional packages (user selection via gum UI)
source "$MAKARON_PATH/install/packages.sh"

EXISTING_SELECTIONS=$(load_package_selections)

if [ -n "$EXISTING_SELECTIONS" ]; then
    echo ""
    echo "Installing previously selected packages..."
    install_selected_packages "$EXISTING_SELECTIONS"
else
    show_package_selector
fi

# Install Todoist CLI for SketchyBar integration.
install_npm_global_package "@doist/todoist-cli" "Todoist CLI" || true

# System settings and migrations (always run)
source "$MAKARON_PATH/install/macos_settings.sh"
source "$MAKARON_PATH/install/migrations.sh"
