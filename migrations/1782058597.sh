#!/bin/bash
# Migration: Remove themes, borders, and dynamic gaps
# Cleans state left by the old theme/borders/gaps system.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Remove themes, borders, and dynamic gaps"

MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
MAKARON_CONF="$HOME/.config/makaron/makaron.conf"
PACKAGES_CONF="${MAKARON_PACKAGES_CONF:-$HOME/.config/makaron/packages.conf}"
UI_MODE_FILE="$HOME/.local/state/makaron/ui-mode"

killall borders 2>/dev/null || true
killall Ice 2>/dev/null || true
rm -f "$MAKARON_PATH/current-theme"
rm -f "$MAKARON_PATH/bin/makaron-set-accent-color"

if command -v brew >/dev/null 2>&1; then
    brew uninstall --cask --force jordanbaird-ice 2>/dev/null || true
    brew uninstall --force tmux 2>/dev/null || true
    brew uninstall --force fresh-editor 2>/dev/null || true
fi
rm -rf "/Applications/Ice.app" 2>/dev/null || true
echo "  ✓ Removed Ice application"
echo "  ✓ Removed tmux and Fresh Editor"

if [ -f "$MAKARON_CONF" ]; then
    sed -i '' '/^BORDERS_ENABLED=/d;/^GAPS_ZERO_ENABLED=/d' "$MAKARON_CONF"
    echo "  ✓ Removed old borders/gaps config keys"
fi

if [ -f "$PACKAGES_CONF" ]; then
    # shellcheck source=/dev/null
    source "$PACKAGES_CONF"
    updated_packages=$(echo "${MAKARON_PACKAGES:-}" | tr ' ' '\n' | { grep -Ev '^(ice|tmux|fresh)$' || true; } | sort -u | tr '\n' ' ' | xargs)
    cat > "$PACKAGES_CONF" << EOF
# Makaron package selections
# Re-run selection: makaron-select-packages
MAKARON_PACKAGES="$updated_packages"
EOF
    echo "  ✓ Removed retired packages from package selections"
fi

clean_shell_config() {
    local config_file="$1"
    [ -f "$config_file" ] || return 0

    sed -i '' '/^export GHOSTTY_THEME=/d' "$config_file"
    sed -i '' '/^# Update Ghostty config from GHOSTTY_THEME/,/^\[ -n "\$GHOSTTY_THEME" \]/d' "$config_file"
}

clean_shell_config "$HOME/.zshrc"
clean_shell_config "$HOME/.bashrc"
echo "  ✓ Removed old Ghostty theme sync from shell configs"

ui_mode="full"
if [ -f "$UI_MODE_FILE" ]; then
    ui_mode="$(head -n 1 "$UI_MODE_FILE" | tr -d '[:space:]')"
    ui_mode="${ui_mode:-full}"
fi

if [ "$ui_mode" != "stop" ] && [ -f "$MAKARON_PATH/bin/makaron-ui-helpers" ]; then
    # shellcheck source=/dev/null
    source "$MAKARON_PATH/bin/makaron-ui-helpers"
    apply_desktop_state || true
fi

echo "  Note: JankyBorders may still be installed. Remove manually with: brew uninstall borders"
echo "Migration completed successfully"
