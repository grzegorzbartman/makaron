#!/bin/sh
# macOS memory for SketchyBar - matches Activity Monitor exactly
# Uses makaron-memory-stats binary (Mach host_statistics64 API)

# Load theme colors
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
THEME_DIR="$MAKARON_PATH/current-theme"
if [ -f "$THEME_DIR/sketchybar.colors" ]; then
  source "$THEME_DIR/sketchybar.colors"
fi

# Get memory stats from Swift binary (uses same API as Activity Monitor)
MEMORY_DISPLAY=$("$MAKARON_PATH/bin/makaron-memory-stats" 2>/dev/null || echo "N/A")

# Update SketchyBar with error handling
sketchybar --set "$NAME" label="$MEMORY_DISPLAY" \
  label.color="${LABEL_COLOR:-0xffc0caf5}" 2>/dev/null || {
  echo "Error updating memory display" >&2
  exit 1
}
