#!/bin/bash
# install/makaron-conf.sh: template regeneration keeps user values

CONF="$HOME/.config/makaron/makaron.conf"

# shellcheck source=/dev/null
source "$REPO/install/makaron-conf.sh"
cmp -s "$CONF" "$REPO/templates/makaron.conf.default" && pass "fresh install copies the template" || fail "fresh conf differs from template"
[ -f "$HOME/.config/makaron/aerospace.user.toml.example" ] && pass "override examples seeded" || fail "examples not seeded"

cat > "$CONF" <<'EOF'
AEROSPACE_GAP_SIZE=20
MY_CUSTOM_VAR=hello
EOF
# shellcheck source=/dev/null
source "$REPO/install/makaron-conf.sh"
assert_contains "$CONF" "AEROSPACE_GAP_SIZE=20" "user value wins"
assert_not_contains "$CONF" "AEROSPACE_GAP_SIZE=12" "template default replaced"
assert_contains "$CONF" "MAKARON_CHANNEL=stable" "new template variables added"
assert_contains "$CONF" "# User-defined settings (not managed by Makaron)" "unknown vars get a section"
assert_contains "$CONF" "MY_CUSTOM_VAR=hello" "unknown user var kept"
assert_eq "$(grep -c '^AEROSPACE_GAP_SIZE=' "$CONF")" "1" "no duplicate keys"

cp "$CONF" "$HOME/conf.before"
# shellcheck source=/dev/null
source "$REPO/install/makaron-conf.sh"
cmp -s "$CONF" "$HOME/conf.before" && pass "regeneration is idempotent" || fail "second run changed the file"
