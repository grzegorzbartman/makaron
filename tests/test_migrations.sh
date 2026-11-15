#!/bin/bash
# Self-contained migrations: effect + idempotency in a throwaway HOME

SWIPE="$REPO/migrations/1793443471.sh"
mkdir -p "$HOME/Library/LaunchAgents" "$HOME/.local/share/aerospace-swipe" "$HOME/.config/aerospace-swipe"
echo '<plist/>' > "$HOME/Library/LaunchAgents/com.acsandmann.swipe.plist"
printf 'AEROSPACE_GAP_SIZE=20\nAEROSPACE_SWIPE_FINGERS=4\nAEROSPACE_SWIPE_NATURAL=true\n' > "$HOME/.config/makaron/makaron.conf"

bash "$SWIPE" >/dev/null && pass "swipe cleanup runs" || fail "swipe cleanup failed"
[ ! -e "$HOME/Library/LaunchAgents/com.acsandmann.swipe.plist" ] && [ ! -e "$HOME/.local/share/aerospace-swipe" ] \
    && pass "swipe files removed" || fail "swipe files left behind"
assert_not_contains "$HOME/.config/makaron/makaron.conf" "AEROSPACE_SWIPE_" "swipe vars removed"
assert_contains "$HOME/.config/makaron/makaron.conf" "AEROSPACE_GAP_SIZE=20" "other user values kept"
bash "$SWIPE" >/dev/null && pass "swipe cleanup idempotent" || fail "second run failed"

# makaron-migrate: runs only pending migrations from MAKARON_PATH, real ANSI colors
STATE="$HOME/.local/state/makaron/migrations"
mkdir -p "$STATE"
for f in "$REPO"/migrations/*.sh; do [ "$f" = "$SWIPE" ] || touch "$STATE/$(basename "$f")"; done
OUT="$HOME/migrate.out"
/bin/bash "$REPO/bin/makaron-migrate" > "$OUT" 2>&1
assert_contains "$OUT" "Running migration (1793443471)" "makaron-migrate runs the pending migration"
[ -f "$STATE/1793443471.sh" ] && pass "pending migration marked completed" || fail "state file missing"
assert_not_contains "$OUT" '\e[' "no literal \\e escapes (bash 3.2)"
/bin/bash "$REPO/bin/makaron-migrate" > "$OUT" 2>&1
assert_not_contains "$OUT" "Running migration (" "second run has nothing pending"

# Laptop gap default 0 -> 2: bumps only the old default, leaves other values
GAP="$REPO/migrations/1793534390.sh"
printf 'AEROSPACE_GAP_SIZE=12\nAEROSPACE_GAP_SIZE_LAPTOP=0\n' > "$HOME/.config/makaron/makaron.conf"
bash "$GAP" >/dev/null && pass "gap migration runs" || fail "gap migration failed"
assert_contains "$HOME/.config/makaron/makaron.conf" "AEROSPACE_GAP_SIZE_LAPTOP=2" "laptop gap bumped to 2"
assert_contains "$HOME/.config/makaron/makaron.conf" "AEROSPACE_GAP_SIZE=12" "desktop gap untouched"
printf 'AEROSPACE_GAP_SIZE_LAPTOP=6\n' > "$HOME/.config/makaron/makaron.conf"
bash "$GAP" >/dev/null
assert_contains "$HOME/.config/makaron/makaron.conf" "AEROSPACE_GAP_SIZE_LAPTOP=6" "custom laptop gap kept"
bash "$GAP" >/dev/null && pass "gap migration idempotent" || fail "gap migration second run failed"

# Laptop gap default -> 6: bumps the old defaults 0 and 2, keeps a custom value
GAP6="$REPO/migrations/1793536079.sh"
printf 'AEROSPACE_GAP_SIZE=12\nAEROSPACE_GAP_SIZE_LAPTOP=2\n' > "$HOME/.config/makaron/makaron.conf"
bash "$GAP6" >/dev/null && pass "gap6 migration runs" || fail "gap6 migration failed"
assert_contains "$HOME/.config/makaron/makaron.conf" "AEROSPACE_GAP_SIZE_LAPTOP=6" "laptop gap 2 bumped to 6"
assert_contains "$HOME/.config/makaron/makaron.conf" "AEROSPACE_GAP_SIZE=12" "desktop gap untouched (gap6)"
printf 'AEROSPACE_GAP_SIZE_LAPTOP=0\n' > "$HOME/.config/makaron/makaron.conf"
bash "$GAP6" >/dev/null
assert_contains "$HOME/.config/makaron/makaron.conf" "AEROSPACE_GAP_SIZE_LAPTOP=6" "laptop gap 0 bumped to 6"
printf 'AEROSPACE_GAP_SIZE_LAPTOP=4\n' > "$HOME/.config/makaron/makaron.conf"
bash "$GAP6" >/dev/null
assert_contains "$HOME/.config/makaron/makaron.conf" "AEROSPACE_GAP_SIZE_LAPTOP=4" "custom laptop gap kept (gap6)"
bash "$GAP6" >/dev/null && pass "gap6 migration idempotent" || fail "gap6 second run failed"

# One flat bar: old desktop height 40 -> 32, laptop height key dropped, custom kept
BAR="$REPO/migrations/1794738711.sh"
printf 'SKETCHYBAR_HEIGHT=40\nSKETCHYBAR_HEIGHT_LAPTOP=32\nAEROSPACE_GAP_SIZE=12\n' > "$HOME/.config/makaron/makaron.conf"
bash "$BAR" >/dev/null && pass "flat bar migration runs" || fail "flat bar migration failed"
assert_contains "$HOME/.config/makaron/makaron.conf" "SKETCHYBAR_HEIGHT=32" "bar height 40 moved to 32"
assert_not_contains "$HOME/.config/makaron/makaron.conf" "SKETCHYBAR_HEIGHT_LAPTOP" "laptop bar key removed"
assert_contains "$HOME/.config/makaron/makaron.conf" "AEROSPACE_GAP_SIZE=12" "other values kept (flat bar)"
printf 'SKETCHYBAR_HEIGHT=36\n' > "$HOME/.config/makaron/makaron.conf"
bash "$BAR" >/dev/null
assert_contains "$HOME/.config/makaron/makaron.conf" "SKETCHYBAR_HEIGHT=36" "custom bar height kept"
bash "$BAR" >/dev/null && pass "flat bar migration idempotent" || fail "flat bar second run failed"

# Tiles guard removal: conf key dropped, flipped workspace back to tiles, state cleared
GUARD="$REPO/migrations/1794738883.sh"
mkdir -p "$HOME/bin"
printf '#!/bin/bash\necho "$*" >> "$HOME/aerospace.calls"\n' > "$HOME/bin/aerospace"; chmod +x "$HOME/bin/aerospace"
printf 'AEROSPACE_LAPTOP_MAX_TILES=2\nAEROSPACE_GAP_SIZE=12\n' > "$HOME/.config/makaron/makaron.conf"
GSTATE="/tmp/makaron-$(id -u)-tiles-guard-zz9"; echo auto > "$GSTATE"
PATH="$HOME/bin:$PATH" bash "$GUARD" >/dev/null && pass "guard removal runs" || fail "guard removal failed"
assert_not_contains "$HOME/.config/makaron/makaron.conf" "AEROSPACE_LAPTOP_MAX_TILES" "max tiles key removed"
assert_contains "$HOME/.config/makaron/makaron.conf" "AEROSPACE_GAP_SIZE=12" "other values kept (guard)"
assert_contains "$HOME/aerospace.calls" "layout --workspace zz9 --root h_tiles" "flipped workspace back to tiles"
[ ! -e "$GSTATE" ] && pass "guard state cleared" || { fail "guard state left"; rm -f "$GSTATE"; }
PATH="$HOME/bin:$PATH" bash "$GUARD" >/dev/null && pass "guard removal idempotent" || fail "guard removal second run failed"
rm -f "$HOME/bin/aerospace"

# Bottom bar: records the Dock position in the snapshot once; stop mode touches nothing
BOTTOM="$REPO/migrations/1794739731.sh"
mkdir -p "$HOME/.local/state/makaron/defaults-snapshot"
: > "$HOME/.local/state/makaron/defaults-snapshot/values"
echo stop > "$HOME/.local/state/makaron/ui-mode"
bash "$BOTTOM" > "$HOME/bottom.out" 2>&1 && pass "bottom bar migration runs (stop)" || fail "bottom bar migration failed"
assert_contains "$HOME/bottom.out" "not in full mode" "stop mode: macOS settings left alone"
assert_contains "$HOME/.local/state/makaron/defaults-snapshot/values" "com.apple.dock|orientation|" "Dock position snapshotted"
bash "$BOTTOM" >/dev/null
[ "$(grep -c '^com.apple.dock|orientation|' "$HOME/.local/state/makaron/defaults-snapshot/values")" = 1 ] \
    && pass "snapshot written once" || fail "snapshot duplicated"
