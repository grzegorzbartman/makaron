#!/bin/bash
# Migration: Remove themes and window borders
# Makaron returns to the native macOS look with a translucent SketchyBar.
# Stops and uninstalls JankyBorders, removes its config, and cleans
# theme/borders variables from makaron.conf. Window gaps are kept.
# Wallpaper and macOS appearance are left untouched.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Remove themes and window borders"

BORDERS_FORMULA="felixkratz/formulae/borders"
MAKARON_CONF="$HOME/.config/makaron/makaron.conf"
BORDERS_CONFIG_DIR="$HOME/.config/borders"

if command -v brew >/dev/null 2>&1 && brew list --formula 2>/dev/null | grep -qx borders; then
    brew trust --formula "$BORDERS_FORMULA" >/dev/null 2>&1 || true
    brew services stop "$BORDERS_FORMULA" >/dev/null 2>&1 || true
    killall borders 2>/dev/null || true
    brew uninstall "$BORDERS_FORMULA" >/dev/null 2>&1 || true
    echo "  ✓ JankyBorders stopped and uninstalled"
else
    killall borders 2>/dev/null || true
    echo "  ✓ JankyBorders not installed, nothing to uninstall"
fi

if [ -d "$BORDERS_CONFIG_DIR" ]; then
    rm -f "$BORDERS_CONFIG_DIR/bordersrc"
    rmdir "$BORDERS_CONFIG_DIR" 2>/dev/null || true
    echo "  ✓ Borders config removed"
fi

if [ -f "$MAKARON_CONF" ]; then
    sed -i '' \
        -e '/^MAKARON_THEME=/d' \
        -e '/^THEME_SET_WALLPAPER=/d' \
        -e '/^THEME_SET_MACOS_APPEARANCE=/d' \
        -e '/^BORDERS_ENABLED=/d' \
        -e '/^BORDER_WIDTH=/d' \
        -e '/^# Desktop theme\./d' \
        -e '/^# Theme side effects\./d' \
        -e '/^# Window layout\. A gap applies independently of window borders\.$/d' \
        "$MAKARON_CONF"
    echo "  ✓ Theme and borders settings removed from makaron.conf"
fi

echo "  Note: your current wallpaper was left as-is; change it in System Settings if needed."
echo "Migration completed successfully"
