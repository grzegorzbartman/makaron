#!/bin/bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/makaron-themes-v2.XXXXXX")"
TEST_CONF="$TEST_ROOT/makaron.conf"
TEST_UI_MODE="$TEST_ROOT/ui-mode"
TEST_AEROSPACE="$TEST_ROOT/aerospace.toml"
TEST_NOTCH_CACHE="$TEST_ROOT/notch"
TEST_BIN_DIR="$TEST_ROOT/bin"
TEST_BORDERS_CONFIG="$TEST_ROOT/bordersrc"
TEST_SERVICE_MARKER="$TEST_ROOT/borders-service"
TEST_SERVICE_LOG="$TEST_ROOT/brew-services.log"

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
export BORDERS_CONFIG_PATH="$TEST_BORDERS_CONFIG"

# shellcheck source=bin/makaron-theme-helpers
source "$REPO_ROOT/bin/makaron-theme-helpers"

assert_equal 7 "${#MAKARON_THEME_SLUGS[@]}" "theme registry size"
assert_equal 7 "$(find "$REPO_ROOT/themes" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')" "theme directory count"
assert_equal true "$(sed -n 's/^BORDERS_ENABLED=//p' "$REPO_ROOT/templates/makaron.conf.default")" "default borders"
assert_equal 12 "$(sed -n 's/^AEROSPACE_GAP_SIZE=//p' "$REPO_ROOT/templates/makaron.conf.default")" "default gaps"
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

mkdir -p "$TEST_BIN_DIR"
cat > "$TEST_BIN_DIR/borders" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >> "$TEST_BORDERS_LOG"
EOF
cat > "$TEST_BIN_DIR/brew" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >> "$TEST_SERVICE_LOG"
case "$1:$2:$3" in
    services:start:felixkratz/formulae/borders|services:restart:felixkratz/formulae/borders) touch "$TEST_SERVICE_MARKER" ;;
    services:stop:felixkratz/formulae/borders) rm -f "$TEST_SERVICE_MARKER" ;;
    services:list:*) [ -f "$TEST_SERVICE_MARKER" ] && printf 'borders started\n' ;;
esac
EOF
chmod +x "$TEST_BIN_DIR/borders" "$TEST_BIN_DIR/brew"
export TEST_BORDERS_LOG="$TEST_ROOT/borders.log"
export TEST_SERVICE_MARKER TEST_SERVICE_LOG
(
    borders_running() { [ -f "$TEST_SERVICE_MARKER" ]; }
    borders_service_started() { [ -f "$TEST_SERVICE_MARKER" ]; }
    PATH="$TEST_BIN_DIR:$PATH" start_borders >/dev/null
)
assert_equal "$(printf '%s\n' \
    'trust --json=v1' \
    'trust --formula felixkratz/formulae/borders' \
    'services start felixkratz/formulae/borders')" \
    "$(cat "$TEST_SERVICE_LOG")" "Borders trust must precede qualified service start"
grep -q 'active_color=0xff7fbbb3 inactive_color=0xff475258 width=5' "$TEST_BORDERS_CONFIG" || fail "Borders config missing theme values"

printf 'full\n' > "$TEST_UI_MODE"
sed -i '' 's/^BORDERS_ENABLED=.*/BORDERS_ENABLED=false/' "$TEST_CONF"
PATH=/usr/bin:/bin apply_desktop_state >/dev/null || fail "layout without optional runtime commands"
printf 'stop\n' > "$TEST_UI_MODE"
PATH=/usr/bin:/bin "$REPO_ROOT/bin/makaron-theme" current >/dev/null || fail "theme current without UI commands"

export MAKARON_CONF_DIR="$TEST_ROOT/migration-config"
export MAKARON_CONF="$MAKARON_CONF_DIR/makaron.conf"
PATH="$TEST_BIN_DIR:$PATH" bash "$REPO_ROOT/migrations/1786783412.sh" >/dev/null
: > "$TEST_SERVICE_LOG"
PATH="$TEST_BIN_DIR:$PATH" bash "$REPO_ROOT/migrations/1786788368.sh" >/dev/null
PATH="$TEST_BIN_DIR:$PATH" bash "$REPO_ROOT/migrations/1786788368.sh" >/dev/null
assert_equal 2 "$(grep -c '^trust --formula felixkratz/formulae/borders$' "$TEST_SERVICE_LOG")" "Borders trust migration idempotency"
sed -i '' 's/^BORDERS_ENABLED=.*/BORDERS_ENABLED=false/' "$MAKARON_CONF"
sed -i '' 's/^AEROSPACE_GAP_SIZE=.*/AEROSPACE_GAP_SIZE=0/' "$MAKARON_CONF"
PATH="$TEST_BIN_DIR:$PATH" bash "$REPO_ROOT/migrations/1786784745.sh" >/dev/null
PATH="$TEST_BIN_DIR:$PATH" bash "$REPO_ROOT/migrations/1786784745.sh" >/dev/null
for key in MAKARON_THEME BORDERS_ENABLED BORDER_WIDTH AEROSPACE_GAP_SIZE; do
    assert_equal 1 "$(grep -c "^${key}=" "$MAKARON_CONF")" "migration idempotency: $key"
done
assert_equal true "$(sed -n 's/^BORDERS_ENABLED=//p' "$MAKARON_CONF")" "migration enables borders"
assert_equal 12 "$(sed -n 's/^AEROSPACE_GAP_SIZE=//p' "$MAKARON_CONF")" "migration enables gaps"

CUSTOM_CONF="$TEST_ROOT/custom-makaron.conf"
printf 'BORDERS_ENABLED=false\nAEROSPACE_GAP_SIZE=8\n' > "$CUSTOM_CONF"
MAKARON_CONF="$CUSTOM_CONF" PATH="$TEST_BIN_DIR:$PATH" bash "$REPO_ROOT/migrations/1786784745.sh" >/dev/null
assert_equal false "$(sed -n 's/^BORDERS_ENABLED=//p' "$CUSTOM_CONF")" "migration preserves customized borders"
assert_equal 8 "$(sed -n 's/^AEROSPACE_GAP_SIZE=//p' "$CUSTOM_CONF")" "migration preserves customized gaps"

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
