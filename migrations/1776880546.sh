#!/bin/bash
# Migration: Restore SketchyBar and JankyBorders after MakaronBar removal
# Installs brew packages, sets up symlinks, compiles Swift binaries, starts services

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Restore SketchyBar and JankyBorders"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

# Source install helpers
if [ -f "$MAKARON_PATH/install/helpers.sh" ]; then
    source "$MAKARON_PATH/install/helpers.sh"
fi

# Install SketchyBar
if ! command -v sketchybar &> /dev/null; then
    echo "Installing SketchyBar..."
    brew tap FelixKratz/formulae 2>/dev/null || true
    install_formula_critical "sketchybar" "SketchyBar"
fi

# Install JankyBorders
if ! command -v borders &> /dev/null; then
    echo "Installing JankyBorders..."
    install_formula "borders" "JankyBorders" "borders"
fi

# Setup SketchyBar symlink
if [ -f "$MAKARON_PATH/install/desktop/sketchybar.sh" ]; then
    source "$MAKARON_PATH/install/desktop/sketchybar.sh"
fi

# Setup Borders
if [ -f "$MAKARON_PATH/install/desktop/borders.sh" ]; then
    source "$MAKARON_PATH/install/desktop/borders.sh"
fi

# Kill MakaronBar if still running
killall makaron-bar 2>/dev/null || true

# Reload UI
if [ -f "$MAKARON_PATH/bin/makaron-ui-helpers" ]; then
    source "$MAKARON_PATH/bin/makaron-ui-helpers"
    reload_current_ui 2>/dev/null || true
fi

echo "Migration completed successfully"
