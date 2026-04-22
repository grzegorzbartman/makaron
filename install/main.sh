#!/bin/bash

# ═══════════════════════════════════════════════════════════════════
# MAKARON MAIN INSTALLER
# Called by install.sh after repository is cloned
# This script runs from a file (not pipe), so stdin is free
# ═══════════════════════════════════════════════════════════════════

set -eEo pipefail

export MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
export MAKARON_INSTALL="$MAKARON_PATH/install"
export MAKARON_INSTALL_LOG_FILE="$MAKARON_PATH/log/makaron-install.log"
export PATH="$MAKARON_PATH/bin:$PATH"

mkdir -p "$(dirname "$MAKARON_INSTALL_LOG_FILE")"

cd "$MAKARON_PATH"

echo ""
echo "📦 Installing components..."
echo ""

source "$MAKARON_PATH/install/all.sh"

echo ""
echo "🔧 Setting up PATH..."

touch "$HOME/.zshrc" 2>/dev/null || true
touch "$HOME/.bashrc" 2>/dev/null || true

add_path_to_config() {
    local config_file="$1"
    local path_line='export PATH="$HOME/.local/share/makaron/bin:$PATH"'

    if [ -f "$config_file" ] && grep -q 'makaron/bin' "$config_file" 2>/dev/null; then
        sed -i.bak '/makaron\/bin/d' "$config_file" 2>/dev/null || {
            grep -v 'makaron/bin' "$config_file" > "${config_file}.tmp" && mv "${config_file}.tmp" "$config_file"
        }
    fi

    echo "$path_line" >> "$config_file"
}

add_path_to_config "$HOME/.zshrc"
add_path_to_config "$HOME/.bashrc"

export PATH="$HOME/.local/share/makaron/bin:$PATH"

echo "🔧 Setting permissions..."
if [ -d "$MAKARON_PATH/bin" ]; then
    chmod +x "$MAKARON_PATH/bin"/* 2>/dev/null || true
else
    echo "   ⚠ Warning: $MAKARON_PATH/bin directory not found!"
fi

if grep -q 'makaron/bin' "$HOME/.zshrc" 2>/dev/null; then
    echo "   ✓ PATH added to .zshrc"
else
    echo "   ✗ Failed to add PATH to .zshrc"
fi

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

echo "Core Components:"
check_installed "aerospace" "AeroSpace" || true
check_installed "sketchybar" "SketchyBar" || true
check_installed "borders" "Borders" || true
check_app "Ghostty" || true

if [ -f "$HOME/.config/makaron/packages.conf" ]; then
    source "$HOME/.config/makaron/packages.conf"
    if [ -n "$MAKARON_PACKAGES" ]; then
        _pkg_count=$(echo "$MAKARON_PACKAGES" | wc -w | xargs)
        echo ""
        echo "Optional: $_pkg_count packages selected"
    fi
fi

echo ""

if [ "$INSTALL_FAILED" -eq 1 ]; then
    echo "⚠️  Some critical components failed to install."
    echo ""
    echo "This is often caused by outdated Command Line Tools."
    echo ""
    echo "To fix, run:"
    echo "  sudo rm -rf /Library/Developer/CommandLineTools"
    echo "  sudo xcode-select --install"
    echo ""
    echo "Then run: makaron-reinstall"
else
    echo "✓ All critical components installed successfully!"
    echo ""
    echo "Commands:"
    echo "  makaron-ui-full     - Start UI (full mode: SketchyBar + hidden menu bar)"
    echo "  makaron-ui-minimal  - Start UI (minimal mode: no SketchyBar)"
    echo "  makaron-ui-stop     - Stop UI"
    echo "  makaron-update      - Update"
    echo "  makaron-debug       - Diagnostics"
    echo ""
    echo "To start: makaron-ui-full"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "Run 'source ~/.zshrc' or restart terminal to use commands."

