#!/bin/bash

# Check Xcode Command Line Tools
check_command_line_tools() {
    # Check if CLT is installed
    if ! xcode-select --print-path &>/dev/null; then
        echo "Xcode Command Line Tools not installed."
        echo "Installing now..."
        xcode-select --install
        echo ""
        echo "Please wait for the installation to complete, then run this script again."
        exit 1
    fi

    # Verify CLT works by attempting a simple compile
    # This catches outdated CLT after macOS updates
    local test_file=$(mktemp)
    echo "int main(){return 0;}" > "$test_file.c"
    if ! cc -x c "$test_file.c" -o "$test_file.out" 2>/dev/null; then
        rm -f "$test_file" "$test_file.c" "$test_file.out" 2>/dev/null
        echo ""
        echo "═══════════════════════════════════════════════════════════════════"
        echo "ERROR: Command Line Tools are installed but not working properly."
        echo "This usually happens after a macOS update."
        echo ""
        echo "Please run these commands to fix:"
        echo "  sudo rm -rf /Library/Developer/CommandLineTools"
        echo "  sudo xcode-select --install"
        echo ""
        echo "Then run this installation script again."
        echo "═══════════════════════════════════════════════════════════════════"
        exit 1
    fi
    rm -f "$test_file" "$test_file.c" "$test_file.out" 2>/dev/null
    echo "✓ Command Line Tools verified"
}

check_command_line_tools

LOCAL_BREW_PATH="$HOME/.local/homebrew"

setup_brew_autoupdate() {
    if ! command -v brew &>/dev/null; then
        echo "Brew not found, skipping autoupdate setup"
        return 0
    fi

    # Add tap if not present
    if ! brew tap | grep -q "domt4/autoupdate"; then
        brew tap domt4/autoupdate
    fi

    # Check if already running
    if brew autoupdate status 2>/dev/null | grep -q "installed and running"; then
        echo "Brew autoupdate already configured"
        return 0
    fi

    # Start autoupdate with upgrade and cleanup (24h interval)
    brew autoupdate start --upgrade --cleanup
    echo "Brew autoupdate configured (24h interval with upgrade & cleanup)"
}

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
elif command -v brew &>/dev/null; then
    # Check if global brew exists and is writable by current user
    BREW_PREFIX="$(brew --prefix 2>/dev/null)"
    if [[ -w "$BREW_PREFIX/Cellar" ]]; then
        echo "Homebrew already installed and writable"
    else
        echo "Global Homebrew exists but not writable - installing locally to $LOCAL_BREW_PATH"
        install_local_brew
    fi
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

# Setup autoupdate for all installations
setup_brew_autoupdate
