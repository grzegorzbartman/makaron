#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -eEo pipefail

# Define Makaron locations
export MAKARON_PATH="$HOME/.local/share/makaron"
export MAKARON_INSTALL="$MAKARON_PATH/install"
export MAKARON_INSTALL_LOG_FILE="$MAKARON_PATH/log/makaron-install.log"
export PATH="$MAKARON_PATH/bin:$PATH"

# Repository URL
REPO_URL="https://github.com/grzegorzbartman/makaron.git"

# Clone or update repository
if [ -d "$MAKARON_PATH/.git" ]; then
    echo "Updating existing installation..."
    cd "$MAKARON_PATH"
    git pull origin main
else
    echo "Cloning repository to $MAKARON_PATH..."
    # Remove directory if it exists but is not a git repo
    if [ -d "$MAKARON_PATH" ]; then
        rm -rf "$MAKARON_PATH"
    fi
    git clone "$REPO_URL" "$MAKARON_PATH"
fi

# Create log directory after cloning
mkdir -p "$(dirname "$MAKARON_INSTALL_LOG_FILE")"

# Change to the cloned directory
cd "$MAKARON_PATH"

# Run all installations
echo "Starting installation process..."
bash "$MAKARON_PATH/install/all.sh"

# Add bin directory to PATH
echo "Setting up PATH..."

# Ensure shell config files exist
touch "$HOME/.zshrc" 2>/dev/null || true
touch "$HOME/.bashrc" 2>/dev/null || true

# Function to safely add PATH to config file
add_path_to_config() {
    local config_file="$1"
    local path_line='export PATH="$HOME/.local/share/makaron/bin:$PATH"'

    # Remove old entries if they exist
    if [ -f "$config_file" ] && grep -q 'makaron/bin' "$config_file" 2>/dev/null; then
        sed -i.bak '/makaron\/bin/d' "$config_file" 2>/dev/null || {
            grep -v 'makaron/bin' "$config_file" > "${config_file}.tmp" && mv "${config_file}.tmp" "$config_file"
        }
    fi

    # Add new entry
    echo "$path_line" >> "$config_file"
}

# Add to shell configs
add_path_to_config "$HOME/.zshrc"
add_path_to_config "$HOME/.bashrc"

# Add to current session
export PATH="$HOME/.local/share/makaron/bin:$PATH"

# Set execute permissions on bin files
echo "Setting execute permissions on bin files..."
if [ -d "$MAKARON_PATH/bin" ]; then
    chmod +x "$MAKARON_PATH/bin"/* 2>/dev/null || true
else
    echo "Warning: $MAKARON_PATH/bin directory not found!"
fi

# Verify PATH was added
if grep -q 'makaron/bin' "$HOME/.zshrc" 2>/dev/null; then
    echo "✓ PATH successfully added to .zshrc"
else
    echo "✗ Failed to add PATH to .zshrc"
fi

echo "Added $MAKARON_PATH/bin to PATH in shell config files"

# Installation summary
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "                    INSTALLATION SUMMARY"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

INSTALL_FAILED=0

check_installed() {
    local cmd="$1"
    local name="$2"
    if command -v "$cmd" &>/dev/null; then
        echo "  ✓ $name"
        return 0
    else
        echo "  ✗ $name (not installed)"
        INSTALL_FAILED=1
        return 1
    fi
}

check_app() {
    local app="$1"
    if [ -d "/Applications/$app.app" ]; then
        echo "  ✓ $app"
        return 0
    else
        echo "  ✗ $app (not installed)"
        return 1
    fi
}

echo "Core UI Components:"
check_installed "aerospace" "AeroSpace"
check_installed "sketchybar" "SketchyBar"
check_installed "borders" "Borders"

echo ""
echo "Terminal & Tools:"
check_app "Ghostty"
check_installed "nvim" "Neovim"
check_installed "tmux" "tmux"

echo ""

if [ "$INSTALL_FAILED" -eq 1 ]; then
    echo "⚠️  Some critical components failed to install."
    echo ""
    echo "This is often caused by outdated Command Line Tools after a macOS update."
    echo ""
    echo "To fix, run:"
    echo "  sudo rm -rf /Library/Developer/CommandLineTools"
    echo "  sudo xcode-select --install"
    echo ""
    echo "Then run: makaron-reinstall"
    echo ""
else
    echo "✓ All critical components installed successfully!"
    echo ""
    echo "Available commands:"
    echo "  makaron-ui-start                    - Start UI components (AeroSpace, SketchyBar, Borders)"
    echo "  makaron-ui-stop                     - Stop UI components"
    echo "  makaron-update                      - Update the configuration"
    echo "  makaron-reload-aerospace-sketchybar - Reload all configurations"
    echo "  makaron-debug                       - Show system diagnostic information"
    echo ""
    echo "To enable the UI components, run: makaron-ui-start"
fi

echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "Note: You may need to restart your terminal or run 'source ~/.zshrc' to use the new commands."
