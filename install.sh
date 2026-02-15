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

# Clone or update
if [ -d "$MAKARON_PATH/.git" ]; then
    echo "📥 Updating existing installation..."
    cd "$MAKARON_PATH"
    git update-index --no-skip-worktree configs/ghostty/config 2>/dev/null || true
    git pull origin main || { echo "   ✗ Update failed"; exit 1; }
    git update-index --skip-worktree configs/ghostty/config 2>/dev/null || true
    echo "   ✓ Updated"
else
    echo "📥 Cloning fresh installation..."
    rm -rf "$MAKARON_PATH" 2>/dev/null || true
    mkdir -p "$(dirname "$MAKARON_PATH")"
    git clone "$REPO_URL" "$MAKARON_PATH" || { echo "   ✗ Clone failed"; exit 1; }
    echo "   ✓ Cloned"
fi

echo ""
echo "🚀 Running main installer..."
echo ""

# KEY FIX: Run the installer script directly from FILE
# This avoids stdin issues because bash reads from file, not pipe
cd "$MAKARON_PATH"
bash "$MAKARON_PATH/install/main.sh"
