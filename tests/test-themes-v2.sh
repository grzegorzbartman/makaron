#!/bin/bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/makaron-themes-v2.XXXXXX")"
TEST_CONF="$TEST_ROOT/makaron.conf"
TEST_UI_MODE="$TEST_ROOT/ui-mode"
TEST_AEROSPACE="$TEST_ROOT/aerospace.toml"
TEST_NOTCH_CACHE="$TEST_ROOT/notch"
TEST_BIN_DIR="$TEST_ROOT/bin"

cleanup() {
    if [ -n "${TEST_ROOT:-}" ] && [ -d "$TEST_ROOT" ]; then
        rm -r -- "$TEST_ROOT"
    fi
}
trap cleanup EXIT

fail() {
    echo "FAIL: $1" >&2
    exit 1
}

assert_equal() {
    local expected="$1" actual="$2" message="$3"
    [ "$expected" = "$actual" ] || fail "$message (expected '$expected', got '$actual')"
}

export MAKARON_PATH="$REPO_ROOT"
export MAKARON_CONF_PATH="$TEST_CONF"
export UI_MODE_FILE="$TEST_UI_MODE"
export AEROSPACE_CONFIG_PATH="$TEST_AEROSPACE"
export NOTCH_CACHE_FILE="$TEST_NOTCH_CACHE"

# shellcheck source=bin/makaron-theme-helpers
source "$REPO_ROOT/bin/makaron-theme-helpers"

assert_equal 7 "${#MAKARON_THEME_SLUGS[@]}" "theme registry size"
assert_equal 7 "$(find "$REPO_ROOT/themes" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')" "theme directory count"
for slug in "${MAKARON_THEME_SLUGS[@]}"; do
    load_theme "$slug" >/dev/null || fail "theme validation: $slug"
    [ -x "$REPO_ROOT/bin/makaron-theme-$slug" ] || fail "missing theme wrapper: $slug"
done
assert_equal 7 "$("$REPO_ROOT/bin/makaron-theme" list | wc -l | tr -d ' ')" "theme list size"

printf 'MAKARON_THEME=does-not-exist\n' > "$TEST_CONF"
load_configured_theme >/dev/null 2>&1 || fail "invalid theme fallback"
assert_equal glass-light "$MAKARON_RESOLVED_THEME" "fallback theme"

cat > "$TEST_CONF" <<EOF
MAKARON_THEME=glass-light
THEME_SET_WALLPAPER=false
THEME_SET_MACOS_APPEARANCE=false
BORDERS_ENABLED=false
BORDER_WIDTH=5
AEROSPACE_GAP_SIZE=0
EOF
printf 'stop\n' > "$TEST_UI_MODE"

"$REPO_ROOT/bin/makaron-theme" set everforest >/dev/null
"$REPO_ROOT/bin/makaron-theme" set everforest >/dev/null
assert_equal 1 "$(grep -c '^MAKARON_THEME=' "$TEST_CONF")" "theme set idempotency"
assert_equal everforest "$(sed -n 's/^MAKARON_THEME=//p' "$TEST_CONF")" "saved theme"
if "$REPO_ROOT/bin/makaron-theme" set does-not-exist >/dev/null 2>&1; then
    fail "invalid theme accepted"
fi
assert_equal everforest "$(sed -n 's/^MAKARON_THEME=//p' "$TEST_CONF")" "invalid theme changed config"

"$REPO_ROOT/bin/makaron-borders" on >/dev/null
"$REPO_ROOT/bin/makaron-borders" on >/dev/null
assert_equal 1 "$(grep -c '^BORDERS_ENABLED=' "$TEST_CONF")" "borders idempotency"
assert_equal true "$(sed -n 's/^BORDERS_ENABLED=//p' "$TEST_CONF")" "saved borders"

"$REPO_ROOT/bin/makaron-gaps" 12 >/dev/null
"$REPO_ROOT/bin/makaron-gaps" 12 >/dev/null
assert_equal 1 "$(grep -c '^AEROSPACE_GAP_SIZE=' "$TEST_CONF")" "gaps idempotency"
assert_equal 12 "$(sed -n 's/^AEROSPACE_GAP_SIZE=//p' "$TEST_CONF")" "saved gaps"
if "$REPO_ROOT/bin/makaron-gaps" 41 >/dev/null 2>&1; then
    fail "out-of-range gap accepted"
fi
assert_equal 12 "$(sed -n 's/^AEROSPACE_GAP_SIZE=//p' "$TEST_CONF")" "invalid gap changed config"

# shellcheck source=bin/makaron-ui-helpers
source "$REPO_ROOT/bin/makaron-ui-helpers"
assert_equal '    outer.top = [{ monitor."Built-in" = 12 }, 52]' "$(_expected_outer_top_line full 12 true)" "notched top gap"
assert_equal '    outer.top = 52' "$(_expected_outer_top_line full 12 false)" "non-notched top gap"
assert_equal '    outer.top = [{ monitor."Built-in" = 0 }, 40]' "$(_expected_outer_top_line full 0 true)" "zero gap with notch"
assert_equal '    outer.top = 80' "$(_expected_outer_top_line full 40 false)" "maximum gap without notch"

cat > "$TEST_AEROSPACE" <<EOF
[gaps]
    inner.horizontal = 0
    inner.vertical =   0
    outer.left =       0
    outer.bottom =     0
    outer.top = 40
    outer.right =      0
EOF
printf '1\n' > "$TEST_NOTCH_CACHE"
_set_aerospace_gaps 12 >/dev/null
switch_aerospace_config full 12 >/dev/null
grep -q 'outer.top = \[{ monitor."Built-in" = 12 }, 52\]' "$TEST_AEROSPACE" || fail "notched config write"
assert_equal 5 "$(grep -Ec '= +12$' "$TEST_AEROSPACE")" "all five regular gaps"

printf '0\n' > "$TEST_NOTCH_CACHE"
switch_aerospace_config full 12 >/dev/null
grep -q '^    outer.top = 52$' "$TEST_AEROSPACE" || fail "non-notched config write"

printf 'full\n' > "$TEST_UI_MODE"
sed -i '' 's/^BORDERS_ENABLED=.*/BORDERS_ENABLED=false/' "$TEST_CONF"
PATH=/usr/bin:/bin apply_desktop_state >/dev/null || fail "layout without optional runtime commands"
printf 'stop\n' > "$TEST_UI_MODE"
PATH=/usr/bin:/bin "$REPO_ROOT/bin/makaron-theme" current >/dev/null || fail "theme current without UI commands"

mkdir -p "$TEST_BIN_DIR"
printf '#!/bin/bash\nexit 0\n' > "$TEST_BIN_DIR/borders"
chmod +x "$TEST_BIN_DIR/borders"
export MAKARON_CONF_DIR="$TEST_ROOT/migration-config"
export MAKARON_CONF="$MAKARON_CONF_DIR/makaron.conf"
PATH="$TEST_BIN_DIR:$PATH" bash "$REPO_ROOT/migrations/1786783412.sh" >/dev/null
PATH="$TEST_BIN_DIR:$PATH" bash "$REPO_ROOT/migrations/1786783412.sh" >/dev/null
for key in MAKARON_THEME BORDERS_ENABLED BORDER_WIDTH AEROSPACE_GAP_SIZE; do
    assert_equal 1 "$(grep -c "^${key}=" "$MAKARON_CONF")" "migration idempotency: $key"
done

TEST_SKETCHYBAR_LINK="$TEST_ROOT/sketchybar-link"
TEST_AEROSPACE_LINK="$TEST_ROOT/aerospace-link"
TEST_MEMORY_BINARY="$TEST_BIN_DIR/makaron-memory-stats"
ln -s "$REPO_ROOT/configs/sketchybar" "$TEST_SKETCHYBAR_LINK"
ln -s "$REPO_ROOT/configs/aerospace/.aerospace.toml" "$TEST_AEROSPACE_LINK"
printf '#!/bin/bash\nexit 0\n' > "$TEST_MEMORY_BINARY"
chmod +x "$TEST_MEMORY_BINARY"
doctor_json="$(
    PATH="$TEST_BIN_DIR:$PATH" \
    MAKARON_CONF="$MAKARON_CONF" \
    MAKARON_SKETCHYBAR_LINK="$TEST_SKETCHYBAR_LINK" \
    MAKARON_AEROSPACE_LINK="$TEST_AEROSPACE_LINK" \
    MAKARON_MEMORY_BINARY="$TEST_MEMORY_BINARY" \
    "$REPO_ROOT/bin/makaron-doctor" --json
)"
echo "$doctor_json" | grep -q '"fail":0' || fail "doctor reported a failure: $doctor_json"

echo "Themes v2 tests passed"
