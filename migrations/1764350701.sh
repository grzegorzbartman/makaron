#!/bin/bash
# Migration: AeroSpace 0.20.0 + persistent-workspaces
# Upgrades AeroSpace and reloads config with new persistent-workspaces feature

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: AeroSpace 0.20.0 + persistent-workspaces"

# Upgrade AeroSpace to latest (0.20.0-Beta with persistent-workspaces support)
echo "Upgrading AeroSpace..."
brew upgrade --cask nikitabobko/tap/aerospace 2>/dev/null || true

# Reload config
echo "Reloading AeroSpace config..."
aerospace reload-config 2>/dev/null || true

echo "Migration completed successfully"

