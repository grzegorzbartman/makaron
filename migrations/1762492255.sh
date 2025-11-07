#!/bin/bash

# Migration: Migrate Ghostty theme to environment variable system
# This migration adds GHOSTTY_THEME environment variable support and sync function
# for existing users who already have Ghostty installed

set -e

error_exit() {
  echo -e "\033[31mERROR: Migration failed! Manual intervention required.\033[0m" >&2
  exit 1
}

trap error_exit ERR

echo "Running migration: Migrate Ghostty theme to environment variable system"

MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
GHOSTTY_CONFIG="$MAKARON_PATH/configs/ghostty/config"

# Extract current theme from config file if it exists and GHOSTTY_THEME is not set
if [ -f "$GHOSTTY_CONFIG" ] && [ -z "$GHOSTTY_THEME" ]; then
    CURRENT_THEME=$(grep -E "^[[:space:]]*theme[[:space:]]*=" "$GHOSTTY_CONFIG" | sed 's/^[[:space:]]*theme[[:space:]]*=[[:space:]]*//' | head -n 1 || echo "")

    if [ -n "$CURRENT_THEME" ]; then
        # Check if GHOSTTY_THEME is already in shell configs
        if [ -f "$HOME/.zshrc" ] && grep -q "^export GHOSTTY_THEME=" "$HOME/.zshrc" 2>/dev/null; then
            echo "GHOSTTY_THEME already set in .zshrc, skipping extraction"
        elif [ -f "$HOME/.bashrc" ] && grep -q "^export GHOSTTY_THEME=" "$HOME/.bashrc" 2>/dev/null; then
            echo "GHOSTTY_THEME already set in .bashrc, skipping extraction"
        else
            # Set GHOSTTY_THEME from current config file value
            THEME_VALUE="$CURRENT_THEME"
            echo "Extracted current theme from config: $THEME_VALUE"

            # Add to shell configs
            ensure_shell_configs() {
                touch "$HOME/.zshrc" 2>/dev/null || true
                touch "$HOME/.bashrc" 2>/dev/null || true
            }

            update_ghostty_theme_env() {
                local config_file="$1"
                local theme_value="$2"
                local export_line="export GHOSTTY_THEME=\"$theme_value\""

                # Remove old GHOSTTY_THEME entries if they exist
                if [ -f "$config_file" ] && grep -q "^export GHOSTTY_THEME=" "$config_file" 2>/dev/null; then
                    if [[ "$OSTYPE" == "darwin"* ]]; then
                        sed -i '' '/^export GHOSTTY_THEME=/d' "$config_file"
                    else
                        sed -i '/^export GHOSTTY_THEME=/d' "$config_file"
                    fi
                fi

                # Add new entry
                echo "$export_line" >> "$config_file"
            }

            ensure_shell_configs
            update_ghostty_theme_env "$HOME/.zshrc" "$THEME_VALUE"
            update_ghostty_theme_env "$HOME/.bashrc" "$THEME_VALUE"
            echo "✓ Set GHOSTTY_THEME environment variable from existing config"
        fi
    fi
fi

# Source functions from install script to avoid code duplication
# Note: This will also run installation checks, but they are idempotent
if [ -f "$MAKARON_PATH/install/tools/ghostty.sh" ]; then
    # Source the install script to get functions (installation is idempotent)
    source "$MAKARON_PATH/install/tools/ghostty.sh"
    echo "✓ Added sync function to shell configs (via install script)"
else
    echo "⚠️  install/tools/ghostty.sh not found, skipping sync function setup"
fi

# Mark configs/ghostty/config as skip-worktree so git ignores local changes
if [ -d "$MAKARON_PATH/.git" ] && [ -f "$MAKARON_PATH/configs/ghostty/config" ]; then
    cd "$MAKARON_PATH"
    git update-index --skip-worktree "configs/ghostty/config" 2>/dev/null || true
    echo "✓ Set git skip-worktree for configs/ghostty/config"
fi

echo "Migration completed successfully"
echo "Note: You may need to restart your terminal or run 'source ~/.zshrc' for changes to take effect"

