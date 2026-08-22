#!/bin/sh
# Refresh the version label in the Makaron menu popup.

VERSION=$("$HOME/.local/share/makaron/bin/makaron-version" 2>/dev/null || echo "makaron")
sketchybar --set makaron.version label="Makaron $VERSION" 2>/dev/null
