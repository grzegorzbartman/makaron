#!/bin/bash
# Migration: Fix Ghostty "One Dark" theme error
# Replaces non-existent "One Dark" theme with "TokyoNight Storm" in Ghostty config and shell environment

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Fix Ghostty 'One Dark' theme error"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
GHOSTTY_CONFIG="$HOME/.config/ghostty/config"

# Check if Ghostty config exists
if [ ! -f "$GHOSTTY_CONFIG" ]; then
    echo "Ghostty config not found, skipping"
    exit 0
fi

# Check if config contains "One Dark" theme reference
if ! grep -q "One Dark" "$GHOSTTY_CONFIG" 2>/dev/null; then
    echo "No 'One Dark' theme found in config, already fixed"
    exit 0
fi

echo "Found 'One Dark' theme reference in Ghostty config, replacing with 'TokyoNight Storm'..."

# Replace "One Dark" with "TokyoNight Storm" in config
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' 's/One Dark/TokyoNight Storm/g' "$GHOSTTY_CONFIG"
else
    sed -i 's/One Dark/TokyoNight Storm/g' "$GHOSTTY_CONFIG"
fi

# Also update shell config files if they contain GHOSTTY_THEME with "One Dark"
for config_file in "$HOME/.zshrc" "$HOME/.bashrc"; do
    if [ -f "$config_file" ] && grep -q "GHOSTTY_THEME.*One Dark" "$config_file" 2>/dev/null; then
        echo "Updating $config_file..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' 's/One Dark/TokyoNight Storm/g' "$config_file"
        else
            sed -i 's/One Dark/TokyoNight Storm/g' "$config_file"
        fi
    fi
done

echo "Migration completed successfully"
echo "Note: Reload Ghostty (Cmd+Shift+,) or restart to apply changes"

