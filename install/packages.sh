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
    "tree|tree|directory listing"
)

PKGS_DEV=(
    "composer|Composer|PHP dependency manager"
    "ddev|DDEV|local dev env"
    "gh|GitHub CLI|GitHub from terminal"
    "lazydocker|lazydocker|Docker TUI"
    "lazygit|lazygit|git TUI"
    "node|Node.js|JS runtime"
    "yarn|Yarn|JS packages"
    "pnpm|pnpm|JS packages"
    "fnm|fnm|node version manager"
    "upsun|Upsun CLI|Platform.sh CLI"
    "docker|Docker|containers"
    "pipx|pipx|Python CLI tools"
)

# ── Package Installer ────────────────────────────────────────────

install_package() {
    local id="$1"
    case "$id" in
        # Terminal
        btop)       install_formula "btop" "btop" "btop" ;;
        ffmpeg)     install_formula "ffmpeg" "ffmpeg" "ffmpeg" ;;
        fzf)        install_formula "fzf" "fzf" "fzf" ;;
        htop)       install_formula "htop" "htop" "htop" ;;
        ncdu)       install_formula "ncdu" "ncdu" "ncdu" ;;
        tree)       install_formula "tree" "tree" "tree" ;;
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
        upsun)      install_formula "upsun/tap/platformsh-cli" "Upsun CLI" "platform" ;;
        docker)     install_cask "docker-desktop" "Docker" ;;
        pipx)       source "$MAKARON_PATH/install/development/pipx.sh" ;;
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
    for entry in "${PKGS_TERMINAL[@]}" "${PKGS_DEV[@]}"; do
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
        "Core installed: AeroSpace, SketchyBar, Ghostty, Fonts." \
        "Select additional packages below."

    local total=2
    _show_group_selector "Terminal Tools" 1 "$total" "${PKGS_TERMINAL[@]}"
    _show_group_selector "Development" 2 "$total" "${PKGS_DEV[@]}"

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
        install_package "$id" || true
    done
}
