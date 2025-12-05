#!/bin/bash

# Install Powerlevel10k
BREW_PREFIX="$(brew --prefix)"
install_formula "powerlevel10k" "Powerlevel10k" "ls $BREW_PREFIX/share/powerlevel10k"

# Setup p10k config symlink
P10K_CONFIG="$HOME/.p10k.zsh"
P10K_CONFIG_SRC="$MAKARON_PATH/configs/p10k/p10k.zsh"

if [ ! -L "$P10K_CONFIG" ] && [ ! -f "$P10K_CONFIG" ]; then
    ln -s "$P10K_CONFIG_SRC" "$P10K_CONFIG"
elif [ -L "$P10K_CONFIG" ]; then
    current_target=$(readlink "$P10K_CONFIG")
    if [[ "$current_target" != "$P10K_CONFIG_SRC" ]]; then
        echo "Fixing p10k symlink to point to makaron config..."
        rm "$P10K_CONFIG"
        ln -s "$P10K_CONFIG_SRC" "$P10K_CONFIG"
    fi
else
    # Regular file exists - backup and replace
    echo "Backing up existing p10k config to ~/.p10k.zsh.backup..."
    cp "$P10K_CONFIG" "$HOME/.p10k.zsh.backup"
    rm "$P10K_CONFIG"
    ln -s "$P10K_CONFIG_SRC" "$P10K_CONFIG"
fi

# Add p10k configuration to .zshrc
add_p10k_to_zshrc() {
    local zshrc="$HOME/.zshrc"
    touch "$zshrc" 2>/dev/null || true

    # Instant prompt block (must be at top of .zshrc)
    local instant_prompt='# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi'

    # Theme source line (use brew --prefix for portability)
    local brew_prefix="$(brew --prefix)"
    local theme_source="source $brew_prefix/share/powerlevel10k/powerlevel10k.zsh-theme"

    # Config source line
    local config_source='[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh'

    # Add instant prompt at top if not present
    if ! grep -q "p10k-instant-prompt" "$zshrc" 2>/dev/null; then
        local tmp=$(mktemp)
        echo "$instant_prompt" > "$tmp"
        echo "" >> "$tmp"
        cat "$zshrc" >> "$tmp"
        mv "$tmp" "$zshrc"
    fi

    # Add theme source if not present
    if ! grep -q "powerlevel10k.zsh-theme" "$zshrc" 2>/dev/null; then
        echo "" >> "$zshrc"
        echo "$theme_source" >> "$zshrc"
    fi

    # Add config source if not present
    if ! grep -q "source ~/.p10k.zsh" "$zshrc" 2>/dev/null; then
        echo "" >> "$zshrc"
        echo "# To customize prompt, run \`p10k configure\` or edit ~/.p10k.zsh." >> "$zshrc"
        echo "$config_source" >> "$zshrc"
    fi
}

add_p10k_to_zshrc
