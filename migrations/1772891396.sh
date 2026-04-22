#!/bin/bash
# Migration: Install VSCode/Cursor theme extensions for makaron themes
# Installs color theme extensions needed by vscode.theme files

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Install VSCode/Cursor theme extensions"

EXTENSIONS=(
    "enkia.tokyo-night"
    "Catppuccin.catppuccin-vsc"
    "arcticicestudio.nord-visual-studio-code"
    "jdinhlife.gruvbox"
    "sainnhe.everforest"
    "metaphore.kanagawa-vscode-color-theme"
    "mvllow.rose-pine"
    "mthierman.theme-flexoki"
    "wavebeem.miasma-vscode"
)

install_extensions() {
    local cli_cmd="$1"
    local editor_name="$2"
    local profile_flag="$3"

    if [ ! -x "$cli_cmd" ] && ! command -v "$cli_cmd" &> /dev/null; then
        echo "$editor_name CLI not found, skipping"
        return 0
    fi

    echo "Installing theme extensions for $editor_name${profile_flag:+ (profile: $profile_flag)}..."
    for ext in "${EXTENSIONS[@]}"; do
        echo -n "  $ext... "
        if [ -n "$profile_flag" ]; then
            "$cli_cmd" --profile "$profile_flag" --install-extension "$ext" --force &>/dev/null && echo "done" || echo "skipped"
        else
            "$cli_cmd" --install-extension "$ext" --force &>/dev/null && echo "done" || echo "skipped"
        fi
    done
}

# Detect editor profiles from storage.json
get_profile_names() {
    local storage_json="$1"
    [ ! -f "$storage_json" ] && return
    python3 -c "
import json, sys
with open('$storage_json') as f:
    data = json.load(f)
for p in data.get('userDataProfiles', []):
    name = p.get('name', '')
    if name:
        print(name)
" 2>/dev/null
}

# Use app binary paths to avoid code->cursor symlink issues
VSCODE_CLI="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
CURSOR_CLI="cursor"

# VSCode: default profile + any custom profiles
install_extensions "$VSCODE_CLI" "VSCode"
while IFS= read -r profile; do
    install_extensions "$VSCODE_CLI" "VSCode" "$profile"
done < <(get_profile_names "$HOME/Library/Application Support/Code/User/globalStorage/storage.json")

# Cursor: default profile + any custom profiles
install_extensions "$CURSOR_CLI" "Cursor"
while IFS= read -r profile; do
    install_extensions "$CURSOR_CLI" "Cursor" "$profile"
done < <(get_profile_names "$HOME/Library/Application Support/Cursor/User/globalStorage/storage.json")

echo ""
echo "Migration completed successfully"
