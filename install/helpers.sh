#!/bin/bash

# Helper function to install cask with graceful handling of existing apps
install_cask() {
    local cask_name="$1"
    local app_name="${2:-$cask_name}"
    
    # Check if already installed via brew
    if brew list --cask "$cask_name" &>/dev/null; then
        echo "$app_name already installed via Homebrew"
        return 0
    fi
    
    # Check if app exists in /Applications (installed outside brew)
    if [ -d "/Applications/$app_name.app" ]; then
        echo "$app_name already exists in /Applications, skipping..."
        return 0
    fi
    
    echo "Installing $app_name..."
    brew install --cask "$cask_name" || {
        echo "Warning: Failed to install $app_name (continuing...)"
        return 1
    }
    return 0
}

# Helper for critical formula installs - exits on failure
install_formula_critical() {
    local formula="$1"
    local name="${2:-$formula}"
    local cmd="${3:-$formula}"
    
    if command -v "$cmd" &>/dev/null; then
        echo "$name already installed"
        return 0
    fi
    
    echo "Installing $name..."
    if ! brew install "$formula"; then
        echo ""
        echo "═══════════════════════════════════════════════════════════════════"
        echo "ERROR: Failed to install $name (critical component)"
        echo ""
        echo "This is often caused by outdated Command Line Tools."
        echo "Please run:"
        echo "  sudo rm -rf /Library/Developer/CommandLineTools"
        echo "  sudo xcode-select --install"
        echo ""
        echo "Then run this installation script again."
        echo "═══════════════════════════════════════════════════════════════════"
        exit 1
    fi
}

# Helper for non-critical formula installs - continues on failure
install_formula() {
    local formula="$1"
    local name="${2:-$formula}"
    local cmd="${3:-$formula}"
    
    if command -v "$cmd" &>/dev/null; then
        echo "$name already installed"
        return 0
    fi
    
    echo "Installing $name..."
    brew install "$formula" || {
        echo "Warning: Failed to install $name (continuing...)"
        return 1
    }
    return 0
}

