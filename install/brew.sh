#!/bin/bash

# Install Xcode Command Line Tools
if ! xcode-select --print-path &>/dev/null; then
    xcode-select --install
    exit 1
fi

LOCAL_BREW_PATH="$HOME/.local/homebrew"

install_local_brew() {
    mkdir -p "$LOCAL_BREW_PATH"
    git clone https://github.com/Homebrew/brew "$LOCAL_BREW_PATH"
    eval "$("$LOCAL_BREW_PATH/bin/brew" shellenv)"
    brew update --force --quiet
    chmod -R go-w "$(brew --prefix)/share/zsh" 2>/dev/null || true

    SHELL_RC="$HOME/.zshrc"
    BREW_EXPORT="export PATH=\"$LOCAL_BREW_PATH/bin:\$PATH\""
    if ! grep -qF "$LOCAL_BREW_PATH/bin" "$SHELL_RC" 2>/dev/null; then
        echo "" >> "$SHELL_RC"
        echo "# Homebrew (local installation)" >> "$SHELL_RC"
        echo "$BREW_EXPORT" >> "$SHELL_RC"
    fi
    echo "Local Homebrew installed. Run: source ~/.zshrc"
}

# Check if local brew already installed
if [[ -x "$LOCAL_BREW_PATH/bin/brew" ]]; then
    echo "Local Homebrew already installed"
    exit 0
fi

# Check if global brew exists and is writable by current user
if command -v brew &>/dev/null; then
    BREW_PREFIX="$(brew --prefix 2>/dev/null)"
    if [[ -w "$BREW_PREFIX/Cellar" ]]; then
        echo "Homebrew already installed and writable"
        exit 0
    fi
    echo "Global Homebrew exists but not writable - installing locally to $LOCAL_BREW_PATH"
    install_local_brew
elif [[ -d "/opt/homebrew" ]] || [[ -d "/usr/local/Homebrew" ]]; then
    echo "Global Homebrew detected but not accessible - installing locally to $LOCAL_BREW_PATH"
    install_local_brew
else
    # No global Homebrew - install normally
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi
