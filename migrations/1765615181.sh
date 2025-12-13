#!/bin/bash
# Migration: Install LibreOffice
# Installs LibreOffice office suite for existing users

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Install LibreOffice"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

if [ -f "$MAKARON_PATH/install/helpers.sh" ]; then
    source "$MAKARON_PATH/install/helpers.sh"
else
    echo "Helpers not found, skipping"
    exit 0
fi

install_cask "libreoffice" "LibreOffice"

echo "Migration completed successfully"
