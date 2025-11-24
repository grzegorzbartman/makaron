#!/bin/bash

# Install Ghostty
if ! command -v ghostty &> /dev/null; then
    brew install --cask ghostty
fi

# Setup Ghostty config
mkdir -p "$HOME/.config"
if [ ! -L "$HOME/.config/ghostty" ] && [ ! -d "$HOME/.config/ghostty" ]; then
    ln -s "$MAKARON_PATH/configs/ghostty" "$HOME/.config/ghostty"
else
    # Check if symlink points to wrong location
    if [ -L "$HOME/.config/ghostty" ]; then
        current_target=$(readlink "$HOME/.config/ghostty")
        if [[ "$current_target" != "$MAKARON_PATH/configs/ghostty" ]]; then
            echo "Fixing Ghostty symlink to point to new location..."
            rm "$HOME/.config/ghostty"
            ln -s "$MAKARON_PATH/configs/ghostty" "$HOME/.config/ghostty"
        fi
    else
        read -p "Ghostty config exists. Overwrite? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$HOME/.config/ghostty"
            ln -s "$MAKARON_PATH/configs/ghostty" "$HOME/.config/ghostty"
        fi
    fi
fi

# Add function to update Ghostty config from GHOSTTY_THEME environment variable
# This ensures the config file is synced with the environment variable
add_ghostty_theme_sync() {
    local config_file="$1"
    local sync_function='# Update Ghostty config from GHOSTTY_THEME environment variable
update_ghostty_config_from_env() {
    if [ -n "$GHOSTTY_THEME" ] && [ -f "$HOME/.config/ghostty/config" ]; then
        local theme_string="theme = $GHOSTTY_THEME"
        if grep -qE "^[[:space:]]*theme[[:space:]]*=" "$HOME/.config/ghostty/config" 2>/dev/null; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i "" "s|^[[:space:]]*theme[[:space:]]*=.*|$theme_string|" "$HOME/.config/ghostty/config" 2>/dev/null || true
            else
                sed -i "s|^[[:space:]]*theme[[:space:]]*=.*|$theme_string|" "$HOME/.config/ghostty/config" 2>/dev/null || true
            fi
        fi
    fi
}
# Auto-update on shell start if GHOSTTY_THEME is set
[ -n "$GHOSTTY_THEME" ] && update_ghostty_config_from_env'

    # Remove old function if it exists
    if [ -f "$config_file" ] && grep -q "update_ghostty_config_from_env" "$config_file" 2>/dev/null; then
        # Remove from line with function definition to end of function
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' '/^# Update Ghostty config from GHOSTTY_THEME/,/^\[ -n "\$GHOSTTY_THEME" \]/d' "$config_file" 2>/dev/null || true
        else
            sed -i '/^# Update Ghostty config from GHOSTTY_THEME/,/^\[ -n "\$GHOSTTY_THEME" \]/d' "$config_file" 2>/dev/null || true
        fi
    fi

    # Add function
    echo "" >> "$config_file"
    echo "$sync_function" >> "$config_file"
}

# Add sync function to shell configs
ensure_shell_configs() {
    touch "$HOME/.zshrc" 2>/dev/null || true
    touch "$HOME/.bashrc" 2>/dev/null || true
}

ensure_shell_configs
add_ghostty_theme_sync "$HOME/.zshrc"
add_ghostty_theme_sync "$HOME/.bashrc"

# Mark configs/ghostty/config as skip-worktree so git ignores local changes
# This file is modified by theme switching scripts via GHOSTTY_THEME variable
if [ -d "$MAKARON_PATH/.git" ] && [ -f "$MAKARON_PATH/configs/ghostty/config" ]; then
    cd "$MAKARON_PATH"
    git update-index --skip-worktree "configs/ghostty/config" 2>/dev/null || true
fi
