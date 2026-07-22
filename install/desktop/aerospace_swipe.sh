#!/bin/bash

# Install aerospace-swipe: switch AeroSpace workspaces with trackpad swipes

SWIPE_REPO="https://github.com/acsandmann/aerospace-swipe.git"
SWIPE_DIR="$HOME/.local/share/aerospace-swipe"
SWIPE_CONF_DIR="$HOME/.config/aerospace-swipe"
SWIPE_CONF="$SWIPE_CONF_DIR/config.json"
SWIPE_PLIST="$HOME/Library/LaunchAgents/com.acsandmann.swipe.plist"

[ -f "$HOME/.config/makaron/makaron.conf" ] && source "$HOME/.config/makaron/makaron.conf"
FINGERS="${AEROSPACE_SWIPE_FINGERS:-4}"

# Fetch / update source
if [ -d "$SWIPE_DIR/.git" ]; then
    git -C "$SWIPE_DIR" pull --ff-only || echo "Warning: aerospace-swipe update failed (continuing...)"
else
    git clone "$SWIPE_REPO" "$SWIPE_DIR" || { echo "Warning: aerospace-swipe clone failed (skipping)"; return 0; }
fi

# Apply finger count from makaron.conf (preserve any other user tweaks)
mkdir -p "$SWIPE_CONF_DIR"
if [ -f "$SWIPE_CONF" ] && command -v jq &>/dev/null; then
    tmp="$(jq --argjson f "$FINGERS" '.fingers = $f' "$SWIPE_CONF")" && printf '%s\n' "$tmp" > "$SWIPE_CONF"
else
    cat > "$SWIPE_CONF" <<EOF
{
  "haptic": false,
  "natural_swipe": false,
  "wrap_around": true,
  "skip_empty": true,
  "fingers": $FINGERS
}
EOF
fi

# Build and (re)load the launch agent
[ -f "$SWIPE_PLIST" ] && launchctl unload "$SWIPE_PLIST" 2>/dev/null
(cd "$SWIPE_DIR" && make install) || echo "Warning: aerospace-swipe build failed (continuing...)"

echo "aerospace-swipe: grant Accessibility permission when macOS prompts (System Settings > Privacy & Security > Accessibility)."
