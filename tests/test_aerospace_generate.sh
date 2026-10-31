#!/bin/bash
# bin/makaron-aerospace-generate: merge semantics and fallback

GEN="$HOME/.config/makaron/generated/aerospace.toml"
STATUS="$HOME/.local/state/makaron/aerospace-generate.status"
USER_TOML="$HOME/.config/makaron/aerospace.user.toml"

"$REPO/bin/makaron-aerospace-generate"
assert_eq "$(cat "$STATUS")" "ok" "no user file: status ok"
assert_contains "$GEN" "alt-enter = 'exec-and-forget" "no user file: base bindings kept"
assert_contains "$GEN" "auto-dwindle.sh" "no user file: dwindle catch-all present"

cat > "$USER_TOML" <<'EOF'
[mode.main.binding]
alt-enter = 'exec-and-forget open -na Ghostty'
alt-shift-t = 'layout tiles'

[gaps]
inner.horizontal = 99

[[on-window-detected]]
if.app-id = "com.spotify.client"
run = ["move-node-to-workspace 5"]
EOF
"$REPO/bin/makaron-aerospace-generate" 2>/dev/null
assert_eq "$(cat "$STATUS")" "ok" "user file: status ok"
assert_contains "$GEN" "alt-enter = 'exec-and-forget open -na Ghostty'" "user key wins"
assert_not_contains "$GEN" "new-terminal.sh" "base value of overridden key dropped"
assert_contains "$GEN" "alt-shift-t = 'layout tiles'" "user-only key added"
assert_not_contains "$GEN" "inner.horizontal = 99" "[gaps] override ignored"
DWINDLE=$(line_of "$GEN" "auto-dwindle.sh")
SPOTIFY=$(line_of "$GEN" "com.spotify.client")
BASE_RULE=$(line_of "$GEN" "com.mimestream.Mimestream")
[ "$DWINDLE" -lt "$SPOTIFY" ] && [ "$SPOTIFY" -lt "$BASE_RULE" ] \
    && pass "user rule runs after dwindle, before base routing" \
    || fail "rule order (dwindle=$DWINDLE user=$SPOTIFY base=$BASE_RULE)"

echo "AEROSPACE_AUTO_DWINDLE=false" > "$HOME/.config/makaron/makaron.conf"
"$REPO/bin/makaron-aerospace-generate" 2>/dev/null
assert_not_contains "$GEN" "auto-dwindle.sh" "AEROSPACE_AUTO_DWINDLE=false drops the catch-all"
rm "$HOME/.config/makaron/makaron.conf"

cat > "$USER_TOML" <<'EOF'
[mode.main.binding]
alt-t = ['layout tiles',
         'mode main']
EOF
"$REPO/bin/makaron-aerospace-generate" 2>/dev/null
assert_eq "$(cut -d' ' -f1 "$STATUS")" "fallback" "multi-line value: fallback status"
assert_contains "$GEN" "base only" "multi-line value: base-only output"
assert_contains "$GEN" "alt-enter = 'exec-and-forget \$HOME" "multi-line value: base bindings intact"
[ -f "$GEN.lastgood" ] && pass "previous output kept as .lastgood" || fail "missing .lastgood"
