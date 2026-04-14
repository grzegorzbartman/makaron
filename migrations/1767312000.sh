#!/bin/bash
# Migration: Remove Devsense PHP extension and apply editor profile (OBSOLETE)
# Editor profiles have been removed from Makaron. This migration is now a no-op.

set -e
echo "Running migration: Remove Devsense PHP extension"

EXTENSION_ID="DEVSENSE.phptools-vscode"

if command -v cursor &> /dev/null; then
    cursor --uninstall-extension "$EXTENSION_ID" 2>/dev/null || true
fi

if command -v code &> /dev/null; then
    code --uninstall-extension "$EXTENSION_ID" 2>/dev/null || true
fi

echo "Migration completed successfully"
