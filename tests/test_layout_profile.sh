#!/bin/bash
# Layout profile: gap / bar / accordion padding per profile, applied and verified
# in a throwaway toml. Runs in a subshell so the sourced helpers stay local.

mkdir -p "$HOME/bin"
printf '#!/bin/bash\nexit 0\n' > "$HOME/bin/aerospace"; chmod +x "$HOME/bin/aerospace"

(
    export PATH="$HOME/bin:$PATH"
    export MAKARON_CONF_PATH="$HOME/.config/makaron/makaron.conf"
    export AEROSPACE_CONFIG_PATH="$HOME/aerospace.toml"
    export NOTCH_CACHE_FILE="$HOME/notch" SCREEN_CACHE_FILE="$HOME/screen"
    export UI_MODE_FILE="$HOME/.local/state/makaron/ui-mode"
    cp "$REPO/templates/makaron.conf.default" "$MAKARON_CONF_PATH"
    cp "$REPO/configs/aerospace/.aerospace.toml" "$AEROSPACE_CONFIG_PATH"
    echo full > "$UI_MODE_FILE"
    echo "1 32" > "$NOTCH_CACHE_FILE"
    # shellcheck source=/dev/null
    source "$REPO/bin/makaron-ui-helpers"
    FAILED=0

    echo "1470 956 1" > "$SCREEN_CACHE_FILE"
    assert_eq "$(_get_layout_profile)" laptop "lone Air 13 -> laptop"
    assert_eq "$(_get_gap_size)" 6 "laptop gap default 6"
    assert_eq "$(_get_bar_height)" 32 "laptop bar 32"
    assert_eq "$(_get_bar_y_offset)" 0 "laptop bar flush with the top"
    assert_eq "$(_get_accordion_padding)" 12 "laptop accordion padding 12"
    assert_eq "$(_get_max_tiles)" 2 "laptop max tiles 2"
    apply_desktop_state >/dev/null
    assert_contains "$AEROSPACE_CONFIG_PATH" "accordion-padding = 12" "accordion-padding written (laptop)"
    assert_contains "$AEROSPACE_CONFIG_PATH" '    inner.horizontal = 6' "gaps written (laptop)"
    assert_contains "$AEROSPACE_CONFIG_PATH" '    outer.top = [{ monitor."Built-in" = 6 }, 38]' "outer.top (laptop, notch 32)"
    verify_desktop_state >/dev/null && pass "verify in sync (laptop)" || fail "verify drift (laptop)"

    echo "1470 956 2" > "$SCREEN_CACHE_FILE"
    assert_eq "$(_get_layout_profile)" desktop "Air 13 + monitor -> desktop"
    assert_eq "$(_get_gap_size)" 12 "desktop gap 12"
    assert_eq "$(_get_accordion_padding)" 30 "desktop accordion padding 30"
    assert_eq "$(_get_max_tiles)" 0 "guard off on desktop"
    apply_desktop_state >/dev/null
    assert_contains "$AEROSPACE_CONFIG_PATH" "accordion-padding = 30" "accordion-padding written (desktop)"
    verify_desktop_state >/dev/null && pass "verify in sync (desktop)" || fail "verify drift (desktop)"

    echo "1710 1112 1" > "$SCREEN_CACHE_FILE"
    assert_eq "$(_get_layout_profile)" desktop "More Space Air 13 -> desktop"
    echo "0 0 1" > "$SCREEN_CACHE_FILE"
    assert_eq "$(_get_layout_profile)" desktop "clamshell -> desktop"

    echo "1470 956 2" > "$SCREEN_CACHE_FILE"
    echo "MAKARON_LAYOUT_PROFILE=laptop" >> "$MAKARON_CONF_PATH"
    assert_eq "$(_get_layout_profile)" laptop "forced laptop wins over detection"
    printf 'AEROSPACE_LAPTOP_MAX_TILES=0\nAEROSPACE_ACCORDION_PADDING_LAPTOP=0\n' >> "$MAKARON_CONF_PATH"
    assert_eq "$(_get_max_tiles)" 0 "max tiles 0 disables"
    assert_eq "$(_get_accordion_padding)" 0 "padding override 0"

    exit "$FAILED"
) || fail "layout profile subshell"
rm -f "$HOME/bin/aerospace"
