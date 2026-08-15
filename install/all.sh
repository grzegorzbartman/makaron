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

# System settings and migrations (always run)
source "$MAKARON_PATH/install/macos_settings.sh"

# Apply the selected theme on fresh install/reinstall. Updates preserve the
# current desktop and only reload its already-selected colors.
if [ -f "$MAKARON_PATH/bin/makaron-theme-helpers" ]; then
    source "$MAKARON_PATH/bin/makaron-theme-helpers"
    selected_theme="$(configured_theme_slug)"
    load_theme "$selected_theme" >/dev/null 2>&1 || selected_theme="$MAKARON_DEFAULT_THEME"
    bash "$MAKARON_PATH/bin/makaron-theme" set "$selected_theme" || true
fi

source "$MAKARON_PATH/install/migrations.sh"
