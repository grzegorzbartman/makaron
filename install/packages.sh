#!/bin/bash

# ═══════════════════════════════════════════════════════════════════
# MAKARON OPTIONAL PACKAGES
# Package registry, gum selection UI, and installer
# ═══════════════════════════════════════════════════════════════════

PACKAGES_CONF="$HOME/.config/makaron/packages.conf"

# ── Package Registry ─────────────────────────────────────────────
# Format: "id|Display Name|description"

PKGS_TERMINAL=(
    "btop|btop|system monitor"
    "ffmpeg|ffmpeg|video/audio tool"
    "fzf|fzf|fuzzy finder"
    "htop|htop|process viewer"
    "ncdu|ncdu|disk usage analyzer"
    "tmux|tmux|terminal multiplexer"
    "tree|tree|directory listing"
    "fresh|Fresh Editor|terminal editor"
    "p10k|Powerlevel10k|zsh theme"
)

PKGS_EDITORS=(
    "vscode|Visual Studio Code|code editor"
    "cursor|Cursor|AI code editor"
    "sublime|Sublime Text|text editor"
    "neovim|Neovim + LazyVim|terminal editor"
)

PKGS_AI=(
    "chatgpt|ChatGPT|AI assistant"
    "claude-app|Claude|AI assistant"
    "gemini-cli|Gemini CLI|AI CLI tool"
    "codex|Codex|AI coding tool"
    "cursor|Cursor|AI code editor"
    "claude-code|Claude Code|AI coding CLI"
    "opencode|OpenCode|AI coding tool"
)

PKGS_DEV=(
    "composer|Composer|PHP packages"
    "ddev|DDEV|local dev env"
    "gh|GitHub CLI|GitHub from terminal"
    "lazydocker|lazydocker|Docker TUI"
    "lazygit|lazygit|git TUI"
    "node|Node.js|JS runtime"
    "yarn|Yarn|JS packages"
    "pnpm|pnpm|JS packages"
    "fnm|fnm|node version manager"
    "upsun|Upsun CLI|Platform.sh CLI"
    "bruno|Bruno|API client"
    "docker|Docker|containers"
    "sequel-ace|Sequel Ace|database GUI"
    "pipx|pipx|Python CLI tools"
    "rbenv|rbenv|Ruby versions"
)

PKGS_DESKTOP=(
    "alttab|AltTab|window switcher"
    "command-x|Command X|cut files in Finder"
    "stats|Stats|system monitor menubar"
)

PKGS_APPS=(
    "flameshot|Flameshot|screenshots"
    "slack|Slack|team chat"
    "spotify|Spotify|music"
    "vlc|VLC|media player"
)

# ── Package Installer ────────────────────────────────────────────

_apply_editor_profile() {
    if [ -x "$MAKARON_PATH/bin/makaron-apply-editor-profile" ]; then
        "$MAKARON_PATH/bin/makaron-apply-editor-profile" development-php-drupal 2>/dev/null || true
    fi
}

install_package() {
    local id="$1"
    case "$id" in
        # Terminal
        btop)       install_formula "btop" "btop" "btop" ;;
        ffmpeg)     install_formula "ffmpeg" "ffmpeg" "ffmpeg" ;;
        fzf)        install_formula "fzf" "fzf" "fzf" ;;
        htop)       install_formula "htop" "htop" "htop" ;;
        ncdu)       install_formula "ncdu" "ncdu" "ncdu" ;;
        tmux)       install_formula "tmux" "tmux" "tmux" ;;
        tree)       install_formula "tree" "tree" "tree" ;;
        fresh)
            brew tap sinelaw/fresh 2>/dev/null || true
            install_formula "fresh-editor" "Fresh Editor" "fresh"
            ;;
        p10k) source "$MAKARON_PATH/install/terminal/p10k.sh" ;;
        # Editors
        vscode)
            install_cask "visual-studio-code" "Visual Studio Code"
            _apply_editor_profile
            ;;
        cursor)
            install_cask "cursor" "Cursor"
            _apply_editor_profile
            ;;
        sublime)    install_cask "sublime-text" "Sublime Text" ;;
        neovim)     source "$MAKARON_PATH/install/editors/neovim_lazyvim.sh" ;;
        # AI
        chatgpt)    install_cask "chatgpt" "ChatGPT" ;;
        claude-app) install_cask "claude" "Claude" ;;
        gemini-cli) install_formula "gemini-cli" "Gemini CLI" "gemini" ;;
        codex)      install_cask "codex" "Codex" ;;
        claude-code)
            if command -v claude &>/dev/null; then
                echo "Claude Code already installed"
            else
                install_cask "claude-code" "Claude Code"
            fi
            ;;
        opencode)
            install_formula "anomalyco/tap/opencode" "OpenCode" "opencode"
            install_cask "opencode-desktop" "OpenCode"
            ;;
        # Development
        composer)   install_formula "composer" "Composer" "composer" ;;
        ddev)       install_formula "ddev/ddev/ddev" "DDEV" "ddev" ;;
        gh)         install_formula "gh" "GitHub CLI" "gh" ;;
        lazydocker) install_formula "lazydocker" "lazydocker" "lazydocker" ;;
        lazygit)    install_formula "lazygit" "lazygit" "lazygit" ;;
        node)       install_formula "node" "Node.js" "node" ;;
        yarn)       install_formula "yarn" "Yarn" "yarn" ;;
        pnpm)       install_formula "pnpm" "pnpm" "pnpm" ;;
        fnm)        source "$MAKARON_PATH/install/development/fnm.sh" ;;
        upsun)      install_formula "platformsh/tap/upsun-cli" "Upsun CLI" "upsun" ;;
        bruno)      install_cask "bruno" "Bruno" ;;
        docker)     install_cask "docker-desktop" "Docker" ;;
        sequel-ace) install_cask "sequel-ace" "Sequel Ace" ;;
        pipx)       source "$MAKARON_PATH/install/development/pipx.sh" ;;
        rbenv)      source "$MAKARON_PATH/install/development/rbenv.sh" ;;
        # Desktop extras
        alttab)     install_cask "alt-tab" "AltTab" ;;
        command-x)  install_cask "command-x" "Command X" ;;
        stats)      install_cask "stats" "Stats" ;;
        # Apps
        flameshot)  install_cask "flameshot" "Flameshot" ;;
        slack)      install_cask "slack" "Slack" ;;
        spotify)    install_cask "spotify" "Spotify" ;;
        vlc)        install_cask "vlc" "VLC" ;;
    esac
}

# ── Persistence ──────────────────────────────────────────────────

save_package_selections() {
    local selections="$1"
    selections=$(echo "$selections" | tr ' ' '\n' | sort -u | tr '\n' ' ' | xargs)
    mkdir -p "$(dirname "$PACKAGES_CONF")"
    cat > "$PACKAGES_CONF" << EOF
# Makaron package selections
# Re-run selection: makaron-select-packages
MAKARON_PACKAGES="$selections"
EOF
}

load_package_selections() {
    if [ -f "$PACKAGES_CONF" ]; then
        source "$PACKAGES_CONF"
        echo "$MAKARON_PACKAGES"
    fi
}

# ── gum UI ───────────────────────────────────────────────────────

_show_group_selector() {
    local group_name="$1"
    local group_num="$2"
    local total="$3"
    shift 3
    local entries=("$@")

    gum style --foreground 212 --bold --margin "1 0 0 0" \
        "── $group_name ($group_num/$total) ──"

    # Extract IDs and build display lines
    local ids=()
    local display_lines=()
    for entry in "${entries[@]}"; do
        local id="${entry%%|*}"
        local rest="${entry#*|}"
        local name="${rest%%|*}"
        local desc="${rest#*|}"
        ids+=("$id")
        display_lines+=("$(printf '%-28s %s' "$name" "$desc")")
    done

    # "Install all?" shortcut
    if gum confirm "Install all $group_name?"; then
        for id in "${ids[@]}"; do
            SELECTED_PACKAGES="$SELECTED_PACKAGES $id"
        done
        return
    fi

    # Individual selection — pre-select based on context
    local selected_args=()
    if [ -z "$EXISTING_PACKAGES" ]; then
        for line in "${display_lines[@]}"; do
            selected_args+=(--selected "$line")
        done
    else
        local idx=0
        for id in "${ids[@]}"; do
            if [[ " $EXISTING_PACKAGES " == *" $id "* ]]; then
                selected_args+=(--selected "${display_lines[$idx]}")
            fi
            ((idx++))
        done
    fi

    local chosen
    chosen=$(printf '%s\n' "${display_lines[@]}" | gum choose \
        --no-limit \
        --height $((${#display_lines[@]} + 3)) \
        --cursor.foreground 212 \
        --selected.foreground 212 \
        --header "  Space = toggle, Enter = confirm" \
        --header.foreground 245 \
        "${selected_args[@]}") || true

    [ -z "$chosen" ] && return

    while IFS= read -r sel_line; do
        [ -z "$sel_line" ] && continue
        local idx=0
        for entry in "${entries[@]}"; do
            if [ "${display_lines[$idx]}" = "$sel_line" ]; then
                SELECTED_PACKAGES="$SELECTED_PACKAGES ${ids[$idx]}"
                break
            fi
            ((idx++))
        done
    done <<< "$chosen"
}

_select_all_packages() {
    local all_pkgs=""
    for entry in "${PKGS_TERMINAL[@]}" "${PKGS_EDITORS[@]}" "${PKGS_AI[@]}" \
                 "${PKGS_DEV[@]}" "${PKGS_DESKTOP[@]}" "${PKGS_APPS[@]}"; do
        all_pkgs="$all_pkgs ${entry%%|*}"
    done
    SELECTED_PACKAGES=$(echo "$all_pkgs" | xargs)
    save_package_selections "$SELECTED_PACKAGES"
    install_selected_packages "$SELECTED_PACKAGES"
}

show_package_selector() {
    EXISTING_PACKAGES="$1"
    SELECTED_PACKAGES=""

    # Non-interactive fallback
    if ! command -v gum &>/dev/null || [ ! -t 0 ]; then
        echo "Non-interactive mode: selecting all optional packages"
        _select_all_packages
        return
    fi

    echo ""
    gum style \
        --border double \
        --border-foreground 212 \
        --padding "1 3" \
        --margin "0 0" \
        --bold \
        --align center \
        "MAKARON" \
        "Package Selection"

    gum style \
        --foreground 245 \
        --italic \
        --margin "0 2" \
        "Core installed: AeroSpace, SketchyBar, Borders, Ghostty, Fonts." \
        "Select additional packages below."

    local total=6
    _show_group_selector "Terminal Tools" 1 "$total" "${PKGS_TERMINAL[@]}"
    _show_group_selector "Code Editors" 2 "$total" "${PKGS_EDITORS[@]}"
    _show_group_selector "AI Tools" 3 "$total" "${PKGS_AI[@]}"
    _show_group_selector "Development" 4 "$total" "${PKGS_DEV[@]}"
    _show_group_selector "Desktop Extras" 5 "$total" "${PKGS_DESKTOP[@]}"
    _show_group_selector "Apps" 6 "$total" "${PKGS_APPS[@]}"

    SELECTED_PACKAGES=$(echo "$SELECTED_PACKAGES" | tr ' ' '\n' | sort -u | tr '\n' ' ' | xargs)

    local count
    count=$(echo "$SELECTED_PACKAGES" | wc -w | xargs)
    echo ""

    if [ "$count" -gt 0 ]; then
        gum style --foreground 82 --bold --margin "0 2" \
            "Selected $count optional packages"

        if ! gum confirm "Install selected packages?"; then
            echo "Cancelled. Run 'makaron-select-packages' to try again."
            save_package_selections ""
            return
        fi
    else
        gum style --foreground 214 --margin "0 2" \
            "No optional packages selected. Run 'makaron-select-packages' to change."
    fi

    save_package_selections "$SELECTED_PACKAGES"
    install_selected_packages "$SELECTED_PACKAGES"
}

# ── Runner ───────────────────────────────────────────────────────

install_selected_packages() {
    local selections="$1"
    [ -z "$selections" ] && return

    echo ""
    echo "Installing optional packages..."
    echo ""

    for id in $selections; do
        install_package "$id"
    done
}
