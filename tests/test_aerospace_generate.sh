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

rm "$USER_TOML"
"$REPO/bin/makaron-aerospace-generate"
assert_contains "$GEN" "focus-follows-mouse.enabled = false" "focus-follows-mouse off by default"
echo "AEROSPACE_FOCUS_FOLLOWS_MOUSE=true" > "$HOME/.config/makaron/makaron.conf"
"$REPO/bin/makaron-aerospace-generate"
assert_contains "$GEN" "focus-follows-mouse.enabled = true" "AEROSPACE_FOCUS_FOLLOWS_MOUSE=true enables it"
echo "focus-follows-mouse.enabled = false # mine" > "$USER_TOML"
"$REPO/bin/makaron-aerospace-generate"
assert_contains "$GEN" "focus-follows-mouse.enabled = false # mine" "user file wins over makaron.conf"
[ "$(grep -c '^focus-follows-mouse' "$GEN")" = 1 ] && pass "focus-follows-mouse key written once" \
    || fail "focus-follows-mouse key duplicated"
rm "$HOME/.config/makaron/makaron.conf"

cat > "$USER_TOML" <<'EOF'
[mode.main.binding]
alt-t = ['layout tiles',  # comment with ] bracket
         'mode main']
EOF
"$REPO/bin/makaron-aerospace-generate"
assert_eq "$(cat "$STATUS")" "ok" "multi-line value: status ok"
assert_contains "$GEN" "         'mode main']" "multi-line value: kept intact"

cat > "$USER_TOML" <<'EOF'
on-window-detected = [
    # TOML 1.1 style from the AeroSpace docs
    {
        if = 'test %{app-bundle-id} = com.google.Chrome || test %{app-bundle-id} = org.mozilla.firefox',
        run = ['move-node-to-workspace 2', "exec-and-forget echo \"a, {b}\""],
    },
    { if.app-id = "com.spotify.client", run = 'move-node-to-workspace 5' },
]
EOF
"$REPO/bin/makaron-aerospace-generate"
assert_eq "$(cat "$STATUS")" "ok" "rule array: status ok"
assert_contains "$GEN" "run = ['move-node-to-workspace 2', \"exec-and-forget echo \\\"a, {b}\\\"\"]" "rule array: commas/braces in strings kept"
assert_contains "$GEN" "if.app-id = \"com.spotify.client\"" "rule array: second rule converted"
[ "$(grep -c '^\[\[on-window-detected\]\]' "$GEN")" = "$(( $(grep -c '^\[\[on-window-detected\]\]' "$REPO/configs/aerospace/.aerospace.toml") + 2 ))" ] \
    && pass "rule array: one table per rule" || fail "rule array: wrong table count"
assert_not_contains "$GEN" "on-window-detected = [" "rule array: no top-level key left"
DWINDLE=$(line_of "$GEN" "auto-dwindle.sh")
CHROME=$(line_of "$GEN" "com.google.Chrome")
BASE_RULE=$(line_of "$GEN" "com.mimestream.Mimestream")
[ "$DWINDLE" -lt "$CHROME" ] && [ "$CHROME" -lt "$BASE_RULE" ] \
    && pass "rule array: runs after dwindle, before base routing" \
    || fail "rule array order (dwindle=$DWINDLE user=$CHROME base=$BASE_RULE)"

cat > "$USER_TOML" <<'EOF'
[mode.main.binding]
alt-t = ['layout tiles',
         'mode main'
EOF
"$REPO/bin/makaron-aerospace-generate" 2>/dev/null
assert_eq "$(cut -d' ' -f1 "$STATUS")" "fallback" "unclosed value: fallback status"
assert_contains "$GEN" "base only" "unclosed value: base-only output"
assert_contains "$GEN" "alt-enter = 'exec-and-forget \$HOME" "unclosed value: base bindings intact"
[ -f "$GEN.lastgood" ] && pass "previous output kept as .lastgood" || fail "missing .lastgood"

sed -n '/^# ---/,$p' "$REPO/templates/aerospace.user.toml.example" | sed 's/^# //' | grep -v '^---' > "$USER_TOML"
"$REPO/bin/makaron-aerospace-generate"
assert_eq "$(cat "$STATUS")" "ok" "example file, fully uncommented: status ok"
assert_contains "$GEN" "if = 'test %{app-bundle-id} = com.google.Chrome" "example file: rule array converted"
