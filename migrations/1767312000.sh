#!/bin/bash
# Migration: Remove Devsense PHP extension and apply updated profile
# Uninstalls DEVSENSE.phptools-vscode and applies development-php-drupal profile

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Remove Devsense PHP extension"

MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
EXTENSION_ID="DEVSENSE.phptools-vscode"

# Uninstall from Cursor if available
if command -v cursor &> /dev/null; then
    cursor --uninstall-extension "$EXTENSION_ID" 2>/dev/null || true
    echo "Removed $EXTENSION_ID from Cursor (or was not installed)"
fi

# Uninstall from VSCode if available
if command -v code &> /dev/null; then
    code --uninstall-extension "$EXTENSION_ID" 2>/dev/null || true
    echo "Removed $EXTENSION_ID from VSCode (or was not installed)"
fi

# Apply updated profile with new settings
if [ -f "$MAKARON_PATH/bin/makaron-apply-editor-profile" ]; then
    echo ""
    echo "Applying updated development-php-drupal profile..."
    "$MAKARON_PATH/bin/makaron-apply-editor-profile" development-php-drupal
fi

echo ""
echo "Migration completed successfully"
