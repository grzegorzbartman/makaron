# AGENTS.md

## What Is Makaron

Makaron is a macOS desktop environment manager for a focused developer setup. It orchestrates AeroSpace for tiling windows, SketchyBar as a fixed top status bar, Ghostty as the terminal, and a set of install/update scripts for optional developer tools.

The desktop layout is intentionally simple: AeroSpace uses zero window gaps, while full UI mode reserves only the 40px SketchyBar height at the top of the screen. Colors are static and live in `configs/sketchybar/colors.sh`.

## General Guidelines
- Read this file for context before making changes.
- Ask 2-6 clarifying questions before implementing changes when requirements are unclear.
- If something doesn't work after 2-3 iterations, search Google using MCP Playwright.

## Contribution Workflow (Default)
Unless the user says otherwise, every change follows this flow:
- Never commit directly to `main`. Create a feature branch first (e.g. `feat/...`, `fix/...`).
- Before committing, run the pre-commit review (`.cursor/skills/pre-commit-review/SKILL.md`):
  - Read this file, then `git status` and `git diff`.
  - Check for breakage risk for both new and existing users (the `makaron-update` path and `migrations/` folder).
  - Check that new keyboard shortcuts don't conflict with Polish characters (lowercase and uppercase: ą, ć, ę, ł, ń, ó, ś, ź, ż, Ą, Ć, Ę, Ł, Ń, Ó, Ś, Ź, Ż).
- Push the branch and open a Pull Request, then return the PR link to the user.

## Code Style
- Short, concise shell scripts - no verbose comments.
- DRY and SOLID principles.
- Commit frequently with single-line messages when the user asks for commits.

## Installation & Updates
- Support both fresh installs and updates.
- Install scripts handle their own symlinks - detect and fix wrong targets automatically.
- Scripts must be idempotent.

### Helper Functions (`install/helpers.sh`)
Use these helpers in install scripts - they handle idempotency and errors gracefully:

```bash
# For GUI apps (casks) - skips if already in /Applications
install_cask "cask-name" "App Name"

# For CLI tools - continues on failure
install_formula "formula" "Display Name" "command-to-check"

# For critical CLI tools - exits on failure with CLT fix instructions
install_formula_critical "formula" "Display Name" "command-to-check"
```

**Important:** Never use `exit` in sourced scripts - use `return` instead, or the entire installation will stop.

**Homebrew paths:** Always use `$(brew --prefix)` instead of hardcoded paths like `/opt/homebrew` - supports Apple Silicon, Intel, and local installs.

### Swift Binaries (`src/`)
Makaron uses one compiled Swift helper for accurate memory reporting:

```bash
swiftc -O -o bin/makaron-memory-stats src/memory_stats.swift
```

- Source files: `src/*.swift`
- Compiled binaries: `bin/` (gitignored)
- Compilation runs automatically during `install/desktop/sketchybar.sh`

### Why Swift
- `memory_stats.swift` uses Mach `host_statistics64` API to match Activity Monitor exactly. Shell-based alternatives (`vm_stat`, `top`) give inaccurate numbers.

---

## User Commands (`bin/`)

All commands are in `bin/` and added to `$PATH` during install.

### UI Mode Commands
Two mutually exclusive modes, persisted in `~/.local/state/makaron/ui-mode`:

| Command | Components | Dock | Menu Bar |
|---|---|---|---|
| `makaron-ui-full` | AeroSpace + SketchyBar | Hidden (autohide) | Hidden (autohide) |
| `makaron-ui-stop` | Nothing | Hidden (autohide) | Visible |

- `makaron-ui-helpers` is a shared library, not a user command. It contains `start/stop_aerospace()`, `start/stop_sketchybar()`, `switch_aerospace_config()`, `apply_macos_full_settings()`, `restore_macos_defaults()`, `save/get_ui_mode()`, and `reload_current_ui()`.

### System Commands
- `makaron-update` - Pulls latest code to installed repo (`git reset --hard origin/main`), runs migrations, reloads UI.
- `makaron-reinstall` - Removes `~/.local/share/makaron/`, re-clones, re-installs.
- `makaron-select-packages` - Re-run optional package selection UI (gum-based).
- `makaron-reload-aerospace-sketchybar` - Reloads AeroSpace + SketchyBar and re-applies layout state.
- `makaron-macos-config-reload` - Re-applies macOS settings from `install/macos_settings.sh`.
- `makaron-doctor` - Concise health check with optional safe repairs.

### Development Commands
- `makaron-dev-add-migration` may not exist in every checkout. If absent, create a timestamped migration manually in `migrations/`.

---

## UI Modes Detail

### AeroSpace Layout
`switch_aerospace_config()` in `makaron-ui-helpers` updates `outer.top` in `~/.aerospace.toml`.

The layout is always gapless:
- `inner.horizontal = 0`
- `inner.vertical = 0`
- `outer.left = 0`
- `outer.bottom = 0`
- `outer.right = 0`

Top reserve:
- **Full mode + no notch:** `outer.top = 40`
- **Full mode + built-in notch:** `outer.top = [{ monitor."Built-in" = 0 }, 40]`

The function resolves the symlink target before editing to modify the actual config file.

### macOS Settings Per Mode
- **Full**: dock autohide, window grouping on (required for AeroSpace), Three Finger Drag off (enables Mission Control), menu bar autohide.
- **Stop**: dock autohide, window grouping off, Three Finger Drag on (restored).

### Menu Bar Autohide
`_set_menubar_autohide()` uses AppleScript to quit and reopen System Settings on the Menu Bar pane, find the dropdown by its current value, then apply a toggle trick (opposite value first, then target). macOS ignores `defaults write` and `CFPreferences` for this setting - UI click is the only reliable method.

---

## SketchyBar Plugins

### Architecture
Plugins live in `configs/sketchybar/plugins/`. Each plugin follows this pattern:
1. Load static colors: `source "$CONFIG_DIR/colors.sh"`
2. Get data (system call, compiled binary, etc.)
3. Update SketchyBar: `sketchybar --set "$NAME" icon="..." label="..." icon.color=$COLOR`

### Color Format
All colors use ARGB hex: `0xffRRGGBB` (ff = fully opaque). Static colors are exported from `configs/sketchybar/colors.sh`.

### SketchyBar Color Variables
`configs/sketchybar/colors.sh` exports:

```bash
# Bar
BAR_COLOR, BAR_BACKGROUND_COLOR, BAR_BLUR
# Items
ICON_COLOR, LABEL_COLOR
# Workspaces (inactive)
SPACE_ICON_COLOR, SPACE_LABEL_COLOR, SPACE_BACKGROUND_COLOR, SPACE_BORDER_COLOR
# Workspaces (focused)
SPACE_FOCUSED_ICON_COLOR, SPACE_FOCUSED_LABEL_COLOR, SPACE_FOCUSED_BACKGROUND_COLOR, SPACE_FOCUSED_BORDER_COLOR
```

### Key Plugins
- **aerospace.sh** - Workspace indicator: shows focused state + app icons (Nerd Font). Multi-monitor aware via `$MONITOR` parameter. On `aerospace_workspace_change` it only refreshes workspaces matching `$FOCUSED_WORKSPACE` or `$PREV_WORKSPACE`; all other senders fall through to the full refresh path. Honors `SKETCHYBAR_HIDE_EMPTY_WORKSPACES` from `makaron.conf` (focused workspace is always drawn).
- **battery.sh** - Battery status with low-threshold warning from `makaron.conf`.
- **memory.sh** - Calls compiled Swift binary `makaron-memory-stats`, shows `X/Y GB`.
- **cpu.sh** - Load average from `uptime` divided by core count.
- **volume.sh** - Detects Bluetooth vs speakers (caches `system_profiler` result for 5s), different icons.
- **display_change.sh** - Invalidates display caches and reapplies layout on every display topology change; reloads SketchyBar when monitor count changes.

### SketchyBar Plugin Conventions
- `$NAME` - item name (set by SketchyBar, identifies which item to update).
- `$INFO` - event data (e.g. volume percentage on `volume_change`).
- Events subscribed via: `--subscribe item_name event_name`.
- Click handlers: `click_script="aerospace workspace $sid"`.

---

## Install Flow

```text
curl -sL install.sh | bash
       |
   install.sh         # Git clone/pull, then runs main.sh FROM FILE (not pipe)
       |
   install/main.sh    # Sources all.sh, sets up PATH in .zshrc/.bashrc, chmod +x bin/
       |
   install/all.sh     # Orchestrates mandatory + optional installs:
       |
       |-- install/mandatory.sh      # Always installed:
       |     |-- helpers.sh
       |     |-- makaron-conf.sh
       |     |-- brew.sh
       |     |-- gum, jq
       |     |-- desktop/ (aerospace, aerospace-swipe, sketchybar, fonts)
       |     |-- terminal/ghostty.sh
       |
       |-- install/packages.sh       # Optional packages:
       |     |-- Fresh install: gum UI per-app selection (6 groups)
       |     └── Update/reinstall: installs from ~/.config/makaron/packages.conf
       |
       |-- macos_settings.sh
       └── migrations.sh
```

**Key detail**: `install.sh` runs `bash "$MAKARON_PATH/install/main.sh"` from file, not piped stdin - this allows interactive `read` prompts and gum UI in install scripts.

### Mandatory vs Optional Packages

**Mandatory** (always installed): Homebrew, Xcode CLT, gum, jq, AeroSpace, aerospace-swipe, SketchyBar, Nerd Fonts, Ghostty.

> aerospace-swipe talks to AeroSpace over the v0.21 socket protocol, so AeroSpace **>= 0.21** is required. `install/desktop/aerospace.sh` upgrades older installs in place (`install_cask` alone skips already-installed apps).

**Optional** (user selects per-app via gum UI, grouped into 6 categories):
- Terminal Tools: btop, cmux, ffmpeg, fzf, htop, ncdu, tree
- Code Editors: VSCode, Cursor, Sublime Text, Neovim + LazyVim
- AI Tools: ChatGPT, Claude, Gemini CLI, Codex, Claude Code, OpenCode
- Development: Composer, DDEV, gh, lazydocker, lazygit, Node.js, Yarn, pnpm, fnm, Upsun CLI, Bruno, Docker, Sequel Ace, pipx, rbenv
- Desktop Extras: Stats
- Apps: Flameshot, Slack, Spotify, VLC

Selections are stored in `~/.config/makaron/packages.conf` (survives update/reinstall). Re-run with `makaron-select-packages`.

---

## Ghostty Configuration

Makaron installs Ghostty but does not manage `~/.config/ghostty`. Terminal appearance and Ghostty preferences are user-owned and stay outside the Makaron repository.

---

## Directory Structure

### Repository Layout
```text
makaron/
├── bin/                    # User commands (added to PATH)
├── configs/                # Config files (symlinked to ~/.config/)
│   ├── aerospace/
│   ├── sketchybar/
│   │   ├── colors.sh
│   │   ├── sketchybarrc
│   │   └── plugins/
├── install/                # Installation scripts
│   ├── all.sh              # Orchestrator: mandatory -> packages -> settings
│   ├── mandatory.sh        # Core components (always installed)
│   ├── packages.sh         # Optional packages: registry, gum UI, installer
│   ├── main.sh             # Main installer (called by install.sh)
│   ├── helpers.sh          # Helper functions
│   ├── brew.sh             # Homebrew + CLT setup
│   ├── desktop/            # AeroSpace, SketchyBar, fonts
│   ├── development/        # Dev tools
│   ├── editors/            # Text editor installers
│   └── terminal/           # Terminal tools
├── migrations/             # Timestamped migration scripts
├── src/                    # Swift source files (compiled to bin/)
└── install.sh              # Bootstrap (clone + call main.sh)
```

### User System Layout
```text
$HOME/
├── .local/share/makaron/            # Clone of repo
├── .local/state/makaron/migrations/ # Migration state
├── .local/state/makaron/ui-mode     # Current UI mode
├── .config/makaron/
│   ├── makaron.conf                 # User settings
│   └── packages.conf                # Optional package selections
├── .config/sketchybar -> ...        # Symlink
└── .aerospace.toml -> ...           # Symlink
```

### Key Paths
```bash
MAKARON_PATH="$HOME/.local/share/makaron"
MAKARON_MIGRATIONS_STATE_PATH="$HOME/.local/state/makaron/migrations"
MAKARON_CONF="$HOME/.config/makaron/makaron.conf"
MAKARON_PACKAGES_CONF="$HOME/.config/makaron/packages.conf"
```

### Development vs Installed Repo
- **Dev repo**: your local clone - where you edit code.
- **Installed repo**: `~/.local/share/makaron/` - separate clone, symlinked to `~/.config/`.

For quick testing you can modify files directly in `~/.local/share/makaron/`, but revert those changes before running `makaron-update`.

---

## User Configuration

### Overview
User-specific settings are stored outside the repo in `~/.config/makaron/makaron.conf`.

### How It Works
- Template: `templates/makaron.conf.default`
- User file: `~/.config/makaron/makaron.conf`
- On install: template is copied to user location
- On update: missing variables are appended (existing values preserved)

### Adding New Config Variables
1. Add variable to `templates/makaron.conf.default`.
2. Use in scripts: `source "$HOME/.config/makaron/makaron.conf"`.
3. Always provide fallback: `VARIABLE="${VARIABLE:-default_value}"`.

### Current Variables
```bash
BATTERY_LOW_THRESHOLD=20                # Battery warning threshold (%)
SKETCHYBAR_COMPACT_MODE=false           # Hide CPU/memory/storage on the right side
SKETCHYBAR_HIDE_EMPTY_WORKSPACES=false  # Hide empty, non-focused workspaces in the bar
AEROSPACE_SWIPE_FINGERS=4               # Trackpad fingers to switch workspaces (aerospace-swipe)
AEROSPACE_SWIPE_NATURAL=true            # Swipe direction; true matches macOS (swipe left -> next)
```

---

## Migration System

### Overview
Database-style migrations provide safe, incremental config updates.

### State Tracking
- **Completed**: Empty file in `~/.local/state/makaron/migrations/`
- **Skipped**: Empty file in `~/.local/state/makaron/migrations/skipped/`
- **Pending**: No file in either location

### When to Create Migrations
- Bug fixes for existing installations
- Moving/renaming config files
- Breaking changes needing gradual rollout
- Adding new software to install scripts (existing users won't get it via update)

### When NOT to Create
- New features not affecting existing installs
- Changes only in `install.sh`
- Documentation updates

### Commands
```bash
makaron-migrate           # Run pending migrations
```

### Migration Template
```bash
#!/bin/bash
# Migration: [Title]
# [Description]

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: [Title]"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

# Check if already applied (idempotent)
if [ condition ]; then
    echo "Already applied, skipping"
    exit 0
fi

# Migration logic here

echo "Migration completed successfully"
```

### Key Patterns
```bash
# Use helpers for installing software (preferred)
if [ -f "$MAKARON_PATH/install/helpers.sh" ]; then
    source "$MAKARON_PATH/install/helpers.sh"
    install_formula "package" "Display Name" "command"
fi

# Source install script with check
if [ -f "$MAKARON_PATH/install/path/script.sh" ]; then
    source "$MAKARON_PATH/install/path/script.sh"
fi

# Graceful service restart
killall ServiceName 2>/dev/null || true
```

### Testing Migrations
1. Syntax: `bash -n migrations/TIMESTAMP.sh`
2. Run manually, verify idempotency (run twice)
3. Test with missing dependencies

## AeroSpace + SketchyBar Integration

### Critical Config
In `configs/aerospace/.aerospace.toml`:

```toml
exec-on-workspace-change = ['/bin/bash', '-c',
    'sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE PREV_WORKSPACE=$AEROSPACE_PREV_WORKSPACE'
]

on-focus-changed = ['exec-and-forget sketchybar --trigger aerospace_focus_change']
```

**Required** - without `exec-on-workspace-change`, empty workspaces won't highlight correctly. `on-focus-changed` keeps the app-icon row up to date when focus moves between windows inside the same workspace.

### SketchyBar Events
Both events are registered in `sketchybarrc`, and every `space.$sid` item subscribes to them plus `front_app_switched`:

```bash
sketchybar --add event aerospace_workspace_change
sketchybar --add event aerospace_focus_change
# ...
--subscribe space.$sid aerospace_workspace_change aerospace_focus_change front_app_switched
```

### Plugin Logic (`aerospace.sh`)
The plugin uses a selective-refresh shortcut for `aerospace_workspace_change`: only the workspaces matching `$FOCUSED_WORKSPACE` and `$PREV_WORKSPACE` actually redraw. All other senders fall through to the full refresh path.

```bash
if [[ "$SENDER" == "aerospace_workspace_change" ]]; then
  if [[ "$WORKSPACE" != "$FOCUSED_WORKSPACE" && "$WORKSPACE" != "$PREV_WORKSPACE" ]]; then
    exit 0
  fi
fi

if [[ -n "$MONITOR" ]]; then
  IS_FOCUSED=$(aerospace list-workspaces --monitor "$MONITOR" --visible 2>/dev/null)
else
  if [[ -z "$FOCUSED_WORKSPACE" ]]; then
    FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null)
  fi
  IS_FOCUSED="$FOCUSED_WORKSPACE"
fi
```

### Hiding Empty Workspaces
`SKETCHYBAR_HIDE_EMPTY_WORKSPACES` in `makaron.conf` (default `false`) hides empty, non-focused workspaces via `drawing=off`. The focused workspace is always drawn, even when empty, so the bar never loses the user's current position.

### Monitor Detection
- Single monitor: Show all workspaces on one bar
- Multi-monitor: Each bar shows only its assigned workspaces
- Auto-reload on monitor connect/disconnect via `display_change.sh`

### Known Issue
`aerospace list-workspaces --focused` fails for empty workspaces - returns last non-empty workspace. Solution: Use event-driven `$FOCUSED_WORKSPACE` from callback.

---

## Troubleshooting

### Diagnostics Tool
Use `makaron-doctor` to check system status:
- Reports component/service health for AeroSpace and SketchyBar
- Verifies symlinks, configs, and UI mode state
- Supports `--fix` for safe repairs and `--json` for machine-readable output

### Migration Not Running
```bash
ls ~/.local/state/makaron/migrations/  # Check if marked completed
rm ~/.local/state/makaron/migrations/TIMESTAMP.sh  # Remove to re-run
makaron-migrate
```

### Empty Workspaces Not Highlighting
Check `exec-on-workspace-change` in aerospace.toml, then `aerospace reload-config`.

### Wrong Workspaces After Monitor Change
```bash
sketchybar --reload
```

### makaron-update Fails (Entry not uptodate / Local changes)
If update fails due to git state, re-run the install script (it fetches latest and fixes skip-worktree):

```bash
curl -sL https://raw.githubusercontent.com/grzegorzbartman/makaron/main/install.sh | bash
```

Then use `makaron-update` or `makaron-update -y` for future updates.
