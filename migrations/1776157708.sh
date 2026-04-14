#!/bin/bash
# Migration: Remove SketchyBar, Borders, UI modes — replace with MakaronBar
# Uninstalls brew formulas, cleans up symlinks/state, renames config vars, compiles makaron-bar

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Remove SketchyBar & Borders, install MakaronBar"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
MAKARON_CONF="$HOME/.config/makaron/makaron.conf"

# 1. Stop and uninstall SketchyBar
if command -v sketchybar &>/dev/null; then
    echo "  Stopping SketchyBar..."
    brew services stop sketchybar 2>/dev/null || true
    echo "  Uninstalling SketchyBar..."
    brew uninstall sketchybar 2>/dev/null || true
fi

# 2. Stop and uninstall Borders
killall borders 2>/dev/null || true
if command -v borders &>/dev/null; then
    brew services stop borders 2>/dev/null || true
    echo "  Uninstalling Borders..."
    brew uninstall borders 2>/dev/null || true
fi

# 3. Untap FelixKratz formulae (no longer needed)
brew untap FelixKratz/formulae 2>/dev/null || true

# 4. Remove SketchyBar config symlink
rm -f "$HOME/.config/sketchybar"

# 5. Remove UI mode state file
rm -f "$HOME/.local/state/makaron/ui-mode"

# 6. Rename SKETCHYBAR_* vars to MAKARON_* in user config
if [ -f "$MAKARON_CONF" ]; then
    sed -i '' \
        -e 's/^SKETCHYBAR_TIMER_TAGS=/MAKARON_TIMER_TAGS=/' \
        -e 's/^SKETCHYBAR_TIMER_DEFAULT_TAG=/MAKARON_TIMER_DEFAULT_TAG=/' \
        -e 's/^SKETCHYBAR_TIMER_RECENT_COUNT=/MAKARON_TIMER_RECENT_COUNT=/' \
        -e 's/^SKETCHYBAR_NOTES_ENABLED=/MAKARON_NOTES_ENABLED=/' \
        -e 's/^SKETCHYBAR_NOTES_FOLDER=/MAKARON_NOTES_FOLDER=/' \
        "$MAKARON_CONF"

    # 7. Remove obsolete vars
    sed -i '' \
        -e '/^BORDERS_ENABLED=/d' \
        -e '/^SKETCHYBAR_TODOIST_ENABLED=/d' \
        -e '/^SKETCHYBAR_CALENDAR_ENABLED=/d' \
        -e '/^SKETCHYBAR_COMPACT_MODE=/d' \
        -e '/^SKETCHYBAR_TIMER_ENABLED=/d' \
        "$MAKARON_CONF"
fi

# 8. Clean Ghostty traces from shell configs
for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
    [ ! -f "$rc" ] && continue
    sed -i '' '/^export GHOSTTY_THEME=/d' "$rc" 2>/dev/null || true
    sed -i '' '/^# Update Ghostty config from GHOSTTY_THEME/,/^\[ -n "\$GHOSTTY_THEME" \]/d' "$rc" 2>/dev/null || true
done

# 9. Compile MakaronBar
if [ -f "$MAKARON_PATH/install/desktop/makaron-bar.sh" ]; then
    echo "  Compiling MakaronBar..."
    source "$MAKARON_PATH/install/desktop/makaron-bar.sh"
fi

# 10. Start MakaronBar
pkill -f makaron-bar 2>/dev/null || true
sleep 0.3
if [ -f "$MAKARON_PATH/bin/makaron-bar" ]; then
    "$MAKARON_PATH/bin/makaron-bar" &
    disown
    echo "  ✓ MakaronBar started"
fi

echo "Migration completed successfully"
