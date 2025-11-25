# AeroSpace + SketchyBar Integration

## Overview

This document explains how AeroSpace window manager integrates with SketchyBar to display workspace indicators with proper highlighting and app icons, including support for single and multi-monitor setups with automatic monitor change detection.

## How It Works

### 1. AeroSpace Configuration

In `configs/aerospace/.aerospace.toml`:

```toml
exec-on-workspace-change = ['/bin/bash', '-c',
    'sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE'
]
```

**Critical:** This callback is REQUIRED. Without it:
- Empty workspaces won't highlight correctly
- The system falls back to querying `aerospace list-workspaces --focused` which doesn't work reliably with empty workspaces

### 2. SketchyBar Configuration

In `configs/sketchybar/sketchybarrc`:

```bash
# Add custom event
sketchybar --add event aerospace_workspace_change

# Detect number of monitors
MONITOR_COUNT=$(aerospace list-monitors | wc -l | tr -d ' ')

if [ "$MONITOR_COUNT" -eq 1 ]; then
  # Single monitor: Show all workspaces
  for sid in $(aerospace list-workspaces --all); do
    sketchybar --add item space.$sid left \
      --subscribe space.$sid aerospace_workspace_change front_app_switched \
      --set space.$sid \
      script="$PLUGIN_DIR/aerospace.sh $sid"
  done
else
  # Multi-monitor: Show only workspaces for each monitor
  for monitor in $(aerospace list-monitors | awk '{print $1}'); do
    for sid in $(aerospace list-workspaces --monitor "$monitor"); do
      sketchybar --add item space.$sid left \
        --subscribe space.$sid aerospace_workspace_change front_app_switched \
        --set space.$sid \
        display="$monitor" \
        script="$PLUGIN_DIR/aerospace.sh $sid $monitor"
    done
  done
fi

# Auto-reload on monitor changes
sketchybar --add item display_change_detector left \
           --set display_change_detector drawing=off \
           script="$PLUGIN_DIR/display_change.sh" \
           --subscribe display_change_detector display_change
```

**Important:** 
- Each workspace subscribes to TWO events:
  - `aerospace_workspace_change` - when switching workspaces
  - `front_app_switched` - when apps change (to update icons)
- **Single monitor mode**: Shows all workspaces (1-10, Q, W, etc.) on one bar
- **Multi-monitor mode**: Each monitor's bar shows only its assigned workspaces
- **Auto-reload**: Automatically reloads when monitors are connected/disconnected

### 3. Plugin Script Logic

In `configs/sketchybar/plugins/aerospace.sh`:

```bash
WORKSPACE=$1
MONITOR=$2

# Multi-monitor support: Check per-monitor visibility
if [[ -n "$MONITOR" ]]; then
  # Get the visible workspace for this specific monitor
  VISIBLE_ON_MONITOR=$(aerospace list-workspaces --monitor "$MONITOR" --visible 2>/dev/null)
  IS_FOCUSED="$VISIBLE_ON_MONITOR"
else
  # Single monitor fallback
  if [[ -z "$FOCUSED_WORKSPACE" ]]; then
    FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null)
  fi
  IS_FOCUSED="$FOCUSED_WORKSPACE"
fi

if [[ "$IS_FOCUSED" == "$WORKSPACE" ]]; then
  # Focused workspace - highlighted
else
  # Inactive workspace
fi
```

**Critical Logic:**
1. **Multi-monitor:** Use `aerospace list-workspaces --monitor X --visible` to check per-monitor visibility
2. **Single monitor:** Use `$FOCUSED_WORKSPACE` environment variable or query aerospace
3. **Fallback:** If empty, query aerospace (for `front_app_switched` events)
4. This hybrid approach handles both single and multi-monitor scenarios correctly

### 4. Monitor Change Detection

In `configs/sketchybar/plugins/display_change.sh`:

```bash
# Get current monitor count
CURRENT_MONITOR_COUNT=$(aerospace list-monitors 2>/dev/null | wc -l | tr -d ' ')

# Store and compare with previous count
MONITOR_COUNT_FILE="/tmp/sketchybar_monitor_count"
PREVIOUS_MONITOR_COUNT=$(cat "$MONITOR_COUNT_FILE" 2>/dev/null || echo "0")
echo "$CURRENT_MONITOR_COUNT" > "$MONITOR_COUNT_FILE"

# Reload if count changed
if [ "$CURRENT_MONITOR_COUNT" != "$PREVIOUS_MONITOR_COUNT" ] && [ "$PREVIOUS_MONITOR_COUNT" != "0" ]; then
  sleep 0.5
  sketchybar --reload
fi
```

**Logic:**
- Tracks monitor count in `/tmp/sketchybar_monitor_count`
- When `display_change` event fires, compares current vs previous count
- If changed: waits 0.5s for system to stabilize, then reloads SketchyBar
- Prevents unnecessary reload on first run (PREVIOUS=0)

## Why This Approach?

### Problem with Querying Aerospace Directly

`aerospace list-workspaces --focused` has a bug/limitation:
- Works fine for workspaces with applications
- **Fails for empty workspaces** - returns the last non-empty focused workspace instead

Example:
```bash
# User is on workspace 8 (empty)
aerospace list-workspaces --focused
# Returns: 3  <- WRONG! This is the last non-empty workspace
```

### Solution: Event-Driven Approach

Using `exec-on-workspace-change`:
- AeroSpace sends `$AEROSPACE_FOCUSED_WORKSPACE` when workspace changes
- Works correctly for ALL workspaces (empty or not)
- Plugin receives reliable data directly

### Why Keep the Fallback?

The `front_app_switched` event doesn't include `$FOCUSED_WORKSPACE`:
- Triggers when apps open/close/switch within current workspace
- Need to update app icons without workspace change
- Must query aerospace in this case (but workspace has apps, so query works)

## Common Mistakes to Avoid

### ❌ DON'T: Remove exec-on-workspace-change

```toml
# BAD - commenting this out breaks empty workspace highlighting
# exec-on-workspace-change = [...]
```

### ❌ DON'T: Only query aerospace

```bash
# BAD - this breaks empty workspaces
FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)
```

### ❌ DON'T: Only use environment variable

```bash
# BAD - this breaks front_app_switched events
if [[ "$FOCUSED_WORKSPACE" == "$WORKSPACE" ]]; then
```

### ✅ DO: Use hybrid approach

```bash
# GOOD - works for all scenarios
if [[ -z "$FOCUSED_WORKSPACE" ]]; then
  FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null)
fi
```

## Testing

### Test Single Monitor Setup

#### Test Empty Workspaces
1. Switch to an empty workspace (e.g., workspace 8)
2. Verify it's highlighted with border
3. Icons should not appear

#### Test Workspaces with Apps
1. Switch to workspace with applications (e.g., workspace 3)
2. Verify it's highlighted with border
3. Icons should appear for running apps
4. Open a new app - icons should update
5. Close an app - icons should update

#### Test Switching Between Workspaces
1. Switch from workspace 3 (with apps) to workspace 8 (empty)
2. Workspace 3 should lose highlight
3. Workspace 8 should gain highlight
4. Repeat in reverse

#### Test All Workspaces Visible
1. With single monitor, verify all workspaces (1-10, Q, W) are visible in SketchyBar
2. Can switch to any workspace and see it highlighted

### Test Multi-Monitor Setup

#### Test Per-Monitor Workspaces
1. Connect second monitor
2. Wait for automatic reload (or run `sketchybar --reload`)
3. Monitor 1 should show only workspaces 1-5
4. Monitor 2 should show only workspaces 6-10, Q, W
5. Each monitor shows only its assigned workspaces

#### Test Independent Highlighting
1. Switch to workspace 2 on monitor 1
2. Switch to workspace Q on monitor 2
3. Monitor 1 should highlight workspace 2
4. Monitor 2 should highlight workspace Q
5. Both highlights should be correct simultaneously

### Test Monitor Connection/Disconnection

#### Test Disconnect Monitor
1. Start with 2 monitors connected
2. Disconnect second monitor
3. SketchyBar should automatically reload (within 1 second)
4. Single monitor now shows all workspaces (1-10, Q, W)
5. All workspaces are accessible

#### Test Connect Monitor
1. Start with 1 monitor
2. Connect second monitor
3. SketchyBar should automatically reload (within 1 second)
4. Monitor 1 shows workspaces 1-5
5. Monitor 2 shows workspaces 6-10, Q, W
6. Each monitor's bar shows only its workspaces

## Event Flow

### Scenario 1: Switch to Empty Workspace (Single Monitor)

```
User: alt-8
  ↓
AeroSpace: exec-on-workspace-change
  ↓
SketchyBar: aerospace_workspace_change FOCUSED_WORKSPACE=8
  ↓
aerospace.sh: $FOCUSED_WORKSPACE is set to 8 (no $MONITOR parameter)
  ↓
All workspaces: Check if $WORKSPACE == 8
  ↓
Workspace 8: Highlight (match!)
Other workspaces: Unhighlight
```

### Scenario 2: Switch to Workspace (Multi-Monitor)

```
User on Monitor 2: alt-q
  ↓
AeroSpace: exec-on-workspace-change
  ↓
SketchyBar: aerospace_workspace_change FOCUSED_WORKSPACE=Q
  ↓
aerospace.sh for workspace Q on monitor 2:
  - $MONITOR is set to 2
  - Query: aerospace list-workspaces --monitor 2 --visible
  - Returns: Q
  ↓
Workspace Q on Monitor 2: Highlight (match!)
  ↓
aerospace.sh for workspace Q on monitor 1 (if exists):
  - Not created (per-monitor items only)
```

### Scenario 3: App Switches on Current Workspace

```
User: Opens new app on workspace 3
  ↓
SketchyBar: front_app_switched event
  ↓
aerospace.sh: $FOCUSED_WORKSPACE is empty
  ↓
aerospace.sh: Query aerospace list-workspaces --focused
  ↓
Returns: 3 (works because workspace has apps)
  ↓
Workspace 3: Update icons, keep highlight
```

### Scenario 4: Monitor Connected/Disconnected

```
User: Disconnects second monitor
  ↓
macOS: display_change event
  ↓
SketchyBar: Triggers display_change_detector
  ↓
display_change.sh:
  - Reads previous count: 2
  - Counts current monitors: 1
  - Detects change: 2 → 1
  - Waits 0.5s
  - Runs: sketchybar --reload
  ↓
SketchyBar reloads:
  - Detects MONITOR_COUNT=1
  - Creates all workspace items (1-10, Q, W)
  - No display assignment
  - Single monitor mode active
```

## Troubleshooting

### Empty workspaces not highlighting

**Check:** Is `exec-on-workspace-change` configured in aerospace.toml?

```bash
grep -A2 "exec-on-workspace-change" ~/.aerospace.toml
```

**Fix:** Add the callback configuration and reload:
```bash
aerospace reload-config
```

### Workspaces with apps losing highlight

**Check:** Does aerospace.sh have the fallback query?

```bash
grep -A3 "if \[\[ -z" ~/.config/sketchybar/plugins/aerospace.sh
```

**Fix:** Add fallback logic to query aerospace when `$FOCUSED_WORKSPACE` is empty.

### Icons not updating

**Check:** Is workspace subscribed to `front_app_switched`?

```bash
grep "front_app_switched" ~/.config/sketchybar/sketchybarrc
```

### Wrong workspaces shown after connecting/disconnecting monitor

**Problem:** After plugging in or removing a monitor, SketchyBar shows wrong workspace set (e.g., only monitor 1 workspaces on single monitor).

**Check:** Is display_change_detector configured?

```bash
grep "display_change_detector" ~/.config/sketchybar/sketchybarrc
```

**Fix:** Manually reload SketchyBar:
```bash
sketchybar --reload
```

Or ensure `display_change.sh` plugin is present and executable:
```bash
ls -la ~/.config/sketchybar/plugins/display_change.sh
```

### Multi-monitor showing same highlight on both monitors

**Problem:** Both monitors show the same workspace as focused.

**Check:** Verify multi-monitor detection:
```bash
aerospace list-monitors | wc -l
```

**Fix:** Ensure sketchybarrc uses per-monitor logic with `display="$monitor"` attribute and passes `$monitor` to aerospace.sh

### Single monitor not showing all workspaces

**Problem:** With one monitor, only seeing subset of workspaces (e.g., 1-5 instead of 1-10, Q, W).

**Check:** Verify monitor count detection:
```bash
aerospace list-monitors | wc -l
# Should show: 1
```

**Fix:** Reload SketchyBar to re-detect monitor count:
```bash
sketchybar --reload
```

## Architecture Summary

```
┌─────────────────────────────────────────────────────────────────┐
│ AeroSpace Window Manager                                        │
│                                                                 │
│ exec-on-workspace-change callback                               │
│   → Sends FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE        │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ SketchyBar                                                      │
│                                                                 │
│ Monitor Detection:                                              │
│  • Counts monitors via aerospace list-monitors                  │
│  • If 1 monitor: Create all workspaces (no display assignment) │
│  • If 2+ monitors: Create per-monitor workspaces               │
│                                                                 │
│ Events:                                                         │
│  • aerospace_workspace_change (with FOCUSED_WORKSPACE var)      │
│  • front_app_switched (no FOCUSED_WORKSPACE var)                │
│  • display_change (monitor connect/disconnect)                  │
└──────────────┬──────────────────────────────┬───────────────────┘
               │                              │
               ▼                              ▼
┌──────────────────────────────┐  ┌──────────────────────────────┐
│ aerospace.sh Plugin          │  │ display_change.sh Plugin     │
│                              │  │                              │
│ Single Monitor:              │  │ Logic:                       │
│  1. Use $FOCUSED_WORKSPACE   │  │  1. Count current monitors   │
│  2. Fallback: query focused  │  │  2. Compare with previous    │
│                              │  │  3. If changed: reload bar   │
│ Multi Monitor:               │  │                              │
│  1. Use --monitor --visible  │  │ Stored state:                │
│  2. Per-monitor highlighting │  │  /tmp/sketchybar_monitor_    │
│                              │  │       count                  │
│ 3. Query apps and icons      │  │                              │
└──────────────────────────────┘  └──────────────────────────────┘
```

## Related Files

- `configs/aerospace/.aerospace.toml` - AeroSpace configuration with callback
- `configs/sketchybar/sketchybarrc` - SketchyBar configuration with single/multi-monitor detection
- `configs/sketchybar/plugins/aerospace.sh` - Plugin script with hybrid logic and per-monitor support
- `configs/sketchybar/plugins/display_change.sh` - Monitor change detection and auto-reload

## References

- [AeroSpace Documentation](https://nikitabobko.github.io/AeroSpace/)
- [SketchyBar Documentation](https://felixkratz.github.io/SketchyBar/)
- [AeroSpace-SketchyBar Integration Guide](https://nikitabobko.github.io/AeroSpace/goodness#show-aerospace-workspaces-in-sketchybar)

