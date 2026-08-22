#!/bin/bash

# ═══════════════════════════════════════════════════════════════════
# MAKARON INSTALLER (Bootstrap)
# This script is safe for curl | bash - it only clones the repo
# and then runs install/main.sh from a FILE (not pipe)
# ═══════════════════════════════════════════════════════════════════

set -e

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "                    MAKARON INSTALLER"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "🔍 System Information:"
echo "   macOS: $(sw_vers -productVersion 2>/dev/null || echo 'unknown')"
echo "   Arch: $(uname -m)"
echo "   User: $USER"
echo "   Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Check git
echo "🔍 Prerequisites:"
if command -v git &>/dev/null; then
    echo "   ✓ git: $(git --version 2>/dev/null | head -1)"
else
    echo "   ✗ git: NOT FOUND"
    echo ""
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install 2>/dev/null || true
    echo ""
    echo "Please wait for installation to complete, then run this command again."
    exit 1
fi

if command -v brew &>/dev/null; then
    echo "   ✓ brew: installed"
else
    echo "   ○ brew: not found (will be installed)"
fi
echo ""

# Paths
MAKARON_PATH="$HOME/.local/share/makaron"
REPO_URL="https://github.com/grzegorzbartman/makaron.git"

echo "📦 Repository:"
echo "   Path: $MAKARON_PATH"
echo ""

# Latest release tag (strict vN.N.N). Full clone required - no --depth.
latest_stable_tag() {
    git tag -l 'v*' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1
}

# Update channel from user config (default stable)
CHANNEL=stable
if [ -f "$HOME/.config/makaron/makaron.conf" ]; then
    CHANNEL=$(sed -n 's/^MAKARON_CHANNEL=//p' "$HOME/.config/makaron/makaron.conf" | tail -1)
fi
case "$CHANNEL" in stable|edge) ;; *) CHANNEL=stable ;; esac

checkout_channel_target() {
    local tag=""
    if [ "$CHANNEL" = "stable" ]; then
        tag="$(latest_stable_tag)" || tag=""
    fi
    if [ -n "$tag" ]; then
        git reset --hard "refs/tags/$tag"
        echo "   ✓ At release $tag (stable channel)"
    else
        git reset --hard origin/main
        echo "   ✓ At latest main"
    fi
}

# Clone or update
if [ -d "$MAKARON_PATH/.git" ]; then
    echo "📥 Updating existing installation..."
    cd "$MAKARON_PATH"
    git fetch --tags --prune --prune-tags --force origin || { echo "   ✗ Update failed"; exit 1; }
    checkout_channel_target
else
    echo "📥 Cloning fresh installation..."
    rm -rf "$MAKARON_PATH" 2>/dev/null || true
    mkdir -p "$(dirname "$MAKARON_PATH")"
    git clone "$REPO_URL" "$MAKARON_PATH" || { echo "   ✗ Clone failed"; exit 1; }
    cd "$MAKARON_PATH"
    checkout_channel_target
    echo "   ✓ Cloned"
fi

echo ""
echo "🚀 Running main installer..."
echo ""

# KEY FIX: Run the installer script directly from FILE
# This avoids stdin issues because bash reads from file, not pipe
cd "$MAKARON_PATH"
bash "$MAKARON_PATH/install/main.sh"
