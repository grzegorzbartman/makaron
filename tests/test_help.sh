#!/bin/bash
# bin/makaron-help --print-html renders the generated config

cat > "$HOME/.config/makaron/aerospace.user.toml" <<'EOF'
[mode.main.binding]
alt-shift-t = 'exec-and-forget my-custom-tool'
EOF
"$REPO/bin/makaron-aerospace-generate" 2>/dev/null
HTML="$HOME/help.html"
MAKARON_HELP_CONFIG="$HOME/.config/makaron/generated/aerospace.toml" "$REPO/bin/makaron-help" --print-html > "$HTML"

assert_contains "$HTML" "<html" "outputs an HTML document"
assert_contains "$HTML" "New terminal window" "base binding described"
assert_contains "$HTML" "<kbd>1–0</kbd>" "workspace bindings collapsed"
assert_contains "$HTML" "my-custom-tool" "unknown user command rendered verbatim"
assert_contains "$HTML" "Service mode" "service mode section"
