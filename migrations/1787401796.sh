#!/bin/bash
# Migration: Install SF Pro font
# SketchyBar labels use Apple's SF Pro from this release on; existing
# installs need the font cask (new installs get it via fonts.sh).

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Install SF Pro font"

if command -v brew >/dev/null 2>&1; then
    brew install --cask font-sf-pro 2>/dev/null || true
    echo "  ✓ SF Pro installed (or already present)"
else
    echo "  ⚠️  Homebrew not found, skipping font install"
fi

echo "Migration completed successfully"
