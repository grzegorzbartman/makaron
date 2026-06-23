#!/bin/bash
# Migration: Detach Powerlevel10k from makaron (preserve user's config)
# p10k is no longer managed by makaron. Users who used the makaron-managed
# config keep their prompt: the symlink is replaced with a real local file.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Detach Powerlevel10k from makaron"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
P10K_LINK="$HOME/.p10k.zsh"
PKGS_CONF="$HOME/.config/makaron/packages.conf"

# Recover the bundled p10k config from git (file is deleted from the working
# tree by `git reset --hard` before this migration runs).
recover_p10k() {
    git -C "$MAKARON_PATH" show 'HEAD@{1}:configs/p10k/p10k.zsh' 2>/dev/null && return 0
    local last
    last=$(git -C "$MAKARON_PATH" log -1 --format=%H -- configs/p10k/p10k.zsh 2>/dev/null)
    [ -n "$last" ] && git -C "$MAKARON_PATH" show "${last}^:configs/p10k/p10k.zsh" 2>/dev/null && return 0
    return 1
}

# Only act on makaron-managed p10k symlinks; leave user-owned files alone.
if [ -L "$P10K_LINK" ]; then
    case "$(readlink "$P10K_LINK")" in
        *makaron*)
            content="$(recover_p10k || true)"
            if [ -n "$content" ]; then
                rm -f "$P10K_LINK"
                printf '%s\n' "$content" > "$P10K_LINK"
                echo "  ✓ Copied p10k config to a local ~/.p10k.zsh (detached from makaron)"
            else
                rm -f "$P10K_LINK"
                echo "  ⚠️  Could not recover bundled p10k config; removed dangling symlink."
                echo "     Run 'p10k configure' to regenerate your prompt."
            fi
            ;;
    esac
fi

# Drop p10k from makaron's package selections (registry no longer exists).
if [ -f "$PKGS_CONF" ]; then
    # shellcheck disable=SC1090
    source "$PKGS_CONF"
    new=$(echo "${MAKARON_PACKAGES:-}" | tr ' ' '\n' | grep -vx 'p10k' | tr '\n' ' ' | xargs)
    cat > "$PKGS_CONF" <<EOF
# Makaron package selections
# Re-run selection: makaron-select-packages
MAKARON_PACKAGES="$new"
EOF
fi

echo "Migration completed successfully"
