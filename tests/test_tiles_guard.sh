#!/bin/bash
# configs/aerospace/scripts/tiles-guard.sh against a stub aerospace CLI

GUARD="$REPO/configs/aerospace/scripts/tiles-guard.sh"
WS="guardtest$$"
STATE="/tmp/makaron-$(id -u)-tiles-guard-$WS"
LOG="$HOME/aero.log"
CONF="$HOME/.config/makaron/makaron.conf"

mkdir -p "$HOME/bin"
cat > "$HOME/bin/aerospace" <<'EOF'
#!/bin/bash
echo "$*" >> "$AERO_LOG"
case "$1" in
    list-workspaces) echo "$AERO_WS" ;;
    list-windows) printf '%b' "$AERO_ROWS" ;;
esac
EOF
chmod +x "$HOME/bin/aerospace"

# rows="<window-layout>|<root-layout>\n..." ; prints the aerospace calls made
guard() {
    : > "$LOG"
    AERO_LOG="$LOG" AERO_WS="$WS" AERO_ROWS="$1" PATH="$HOME/bin:$PATH" \
        MAKARON_CONF_PATH="$CONF" SCREEN_CACHE_FILE="$HOME/screen" bash "$GUARD"
    grep -E '^(layout|flatten)' "$LOG" | tr '\n' ';'
}
T3="h_tiles|h_tiles\nh_tiles|h_tiles\nh_tiles|h_tiles\n"
T2="h_tiles|h_tiles\nh_tiles|h_tiles\n"
A3="h_accordion|h_accordion\nh_accordion|h_accordion\nh_accordion|h_accordion\n"
A2="h_accordion|h_accordion\nh_accordion|h_accordion\n"
rm -f "$STATE"

echo "MAKARON_LAYOUT_PROFILE=desktop" > "$CONF"
assert_eq "$(guard "$T3")" "" "desktop: never touches the layout"
[ -s "$LOG" ] && fail "desktop: aerospace was called" || pass "desktop: aerospace not called"

echo "MAKARON_LAYOUT_PROFILE=laptop" > "$CONF"
assert_eq "$(guard "$T2")" "" "2 tiles: nothing to do"
assert_eq "$(guard "$T3")" "flatten-workspace-tree --workspace $WS;layout --workspace $WS --root h_accordion;" "3 tiles: flatten + accordion"
assert_eq "$(cat "$STATE")" auto "state = auto"
assert_eq "$(guard "$A3")" "" "already accordion: nothing to do"
assert_eq "$(guard "$T3")" "" "user tiled it again: left alone"
assert_eq "$(cat "$STATE")" user "state = user"
assert_eq "$(guard "$T3")" "" "still user: left alone"
assert_eq "$(guard "$T2")" "" "user state, back under limit: no layout call"
[ -e "$STATE" ] && fail "state not cleared" || pass "state cleared"

guard "$T3" >/dev/null
assert_eq "$(guard "$A2")" "layout --workspace $WS --root h_tiles;" "auto accordion, window closed: back to tiles"
[ -e "$STATE" ] && fail "state not cleared after revert" || pass "state cleared after revert"

assert_eq "$(guard "h_tiles|h_tiles\nh_tiles|h_tiles\nfloating|h_tiles\nfloating|h_tiles\n")" "" "floating windows not counted"
assert_eq "$(guard "")" "" "empty workspace: nothing"

printf 'MAKARON_LAYOUT_PROFILE=laptop\nAEROSPACE_LAPTOP_MAX_TILES=0\n' > "$CONF"
assert_eq "$(guard "$T3")" "" "max tiles 0: guard off"
printf 'MAKARON_LAYOUT_PROFILE=laptop\nAEROSPACE_LAPTOP_MAX_TILES=3\n' > "$CONF"
assert_eq "$(guard "$T3")" "" "max tiles 3: three tiles allowed"

rm -f "$STATE" "$HOME/bin/aerospace"
