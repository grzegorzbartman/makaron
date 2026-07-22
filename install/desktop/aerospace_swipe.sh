#!/bin/bash

# Install aerospace-swipe: switch AeroSpace workspaces with trackpad swipes

SWIPE_REPO="https://github.com/acsandmann/aerospace-swipe.git"
SWIPE_DIR="$HOME/.local/share/aerospace-swipe"
SWIPE_CONF_DIR="$HOME/.config/aerospace-swipe"
SWIPE_CONF="$SWIPE_CONF_DIR/config.json"
SWIPE_PLIST="$HOME/Library/LaunchAgents/com.acsandmann.swipe.plist"

[ -f "$HOME/.config/makaron/makaron.conf" ] && source "$HOME/.config/makaron/makaron.conf"
FINGERS="${AEROSPACE_SWIPE_FINGERS:-4}"
NATURAL="${AEROSPACE_SWIPE_NATURAL:-true}"
case "$NATURAL" in true|false) ;; *) NATURAL=true ;; esac

# Fetch / update source
if [ -d "$SWIPE_DIR/.git" ]; then
    git -C "$SWIPE_DIR" pull --ff-only || echo "Warning: aerospace-swipe update failed (continuing...)"
else
    git clone "$SWIPE_REPO" "$SWIPE_DIR" || { echo "Warning: aerospace-swipe clone failed (skipping)"; return 0; }
fi

# Apply settings from makaron.conf (preserve any other user tweaks).
# natural_swipe=true matches macOS trackpad direction (swipe left -> next space).
mkdir -p "$SWIPE_CONF_DIR"
if [ -f "$SWIPE_CONF" ] && command -v jq &>/dev/null; then
    tmp="$(jq --argjson f "$FINGERS" --argjson n "$NATURAL" '.fingers = $f | .natural_swipe = $n' "$SWIPE_CONF")" \
        && printf '%s\n' "$tmp" > "$SWIPE_CONF"
else
    cat > "$SWIPE_CONF" <<EOF
{
  "haptic": false,
  "natural_swipe": $NATURAL,
  "wrap_around": true,
  "skip_empty": true,
  "fingers": $FINGERS
}
EOF
fi

# Build the app and install the launch agent
{ [ -f "$SWIPE_PLIST" ] && launchctl unload "$SWIPE_PLIST" 2>/dev/null; } || true
(cd "$SWIPE_DIR" && make install) || echo "Warning: aerospace-swipe build failed (continuing...)"

# aerospace-swipe falls back to the `aerospace` CLI, which isn't on launchd's
# minimal PATH. Inject Homebrew's bin so the fallback works, then reload.
if [ -f "$SWIPE_PLIST" ]; then
    BREW_BIN="$(brew --prefix)/bin"
    /usr/libexec/PlistBuddy -c "Add :EnvironmentVariables dict" "$SWIPE_PLIST" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Add :EnvironmentVariables:PATH string $BREW_BIN:/usr/bin:/bin:/usr/sbin:/sbin" "$SWIPE_PLIST" 2>/dev/null \
        || /usr/libexec/PlistBuddy -c "Set :EnvironmentVariables:PATH $BREW_BIN:/usr/bin:/bin:/usr/sbin:/sbin" "$SWIPE_PLIST" || true
    launchctl unload "$SWIPE_PLIST" 2>/dev/null || true
    launchctl load "$SWIPE_PLIST" 2>/dev/null || true
fi

echo "aerospace-swipe: grant Accessibility permission when macOS prompts (System Settings > Privacy & Security > Accessibility)."
