#!/bin/bash

# Homebrew >= 6.0 refuses to load non-official taps until they are trusted.
# Only tap-qualified names (user/tap/name) need it; no-op on older Homebrew.
brew_trust() {
    local kind="$1" name="$2"
    [[ "$name" == */*/* ]] && brew trust "$kind" "$name" &>/dev/null
    return 0
}

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
    brew_trust --cask "$cask_name"
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
    brew_trust --formula "$formula"
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
    brew_trust --formula "$formula"
    brew install "$formula" || {
        echo "Warning: Failed to install $name (continuing...)"
        return 1
    }
    return 0
}

# Helper for global npm installs - continues on failure
install_npm_global_package() {
    local package="$1"
    local name="${2:-$package}"
    local package_installed=1

    if ! command -v npm &>/dev/null; then
        echo "npm not found, installing Node.js..."
        install_formula "node" "Node.js" "node" || return 1
    fi

    if ! command -v npm &>/dev/null; then
        echo "Warning: npm still not available, skipping $name"
        return 1
    fi

    npm ls -g --depth=0 "$package" &>/dev/null || package_installed=0
    if [ "$package_installed" -eq 1 ]; then
        echo "$name already installed globally"
        return 0
    fi

    echo "Installing $name..."
    npm install -g "$package" || {
        echo "Warning: Failed to install $name (continuing...)"
        return 1
    }
    return 0
}

