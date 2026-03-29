# AGENTS.md

## What Is Makaron

Makaron is a macOS desktop environment manager. It sets up and orchestrates a tiling window manager (AeroSpace), a custom status bar (SketchyBar), window borders (JankyBorders), and a terminal (Ghostty) — all tied together by a theming system that switches colors across every component simultaneously, including VSCode/Cursor, macOS accent color, dark/light mode, and wallpaper.

The project is a collection of bash scripts, SketchyBar plugins, config files, and two Swift binaries. It installs via a single `curl | bash` command and updates itself via `makaron-update`.

## General Guidelines
- Read this file for context before making changes.
- Ask 2-6 clarifying questions before implementing changes.
- If something doesn't work after 2-3 iterations, search Google using MCP Playwright.

## Code Style
- Short, concise shell scripts - no verbose comments.
- DRY and SOLID principles.
- Commit frequently with single-line messages.

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
Some components require compiled Swift binaries for performance or API access:

```bash
# Compile all Swift sources
swiftc -O -o bin/makaron-memory-stats src/memory_stats.swift
swiftc -O -o bin/makaron-set-accent-color src/set_accent_color.swift
```

- Source files: `src/*.swift`
- Compiled binaries: `bin/` (gitignored)
- Compilation runs automatically during `install/desktop/sketchybar.sh`

### Why Swift
- `memory_stats.swift` — Uses Mach `host_statistics64` API to match Activity Monitor exactly. Shell-based alternatives (`vm_stat`, `top`) give inaccurate numbers.
- `set_accent_color.swift` — Uses `CFPreferences` API + `DistributedNotificationCenter` for instant system-wide accent color change with live notification (no logout required).


---

## User Commands (`bin/`)

All commands are in `bin/` and added to `$PATH` during install.

### UI Mode Commands
Three mutually exclusive modes, persisted in `~/.local/state/makaron/ui-mode`:

| Command | Components | Dock | Menu Bar |
|---|---|---|---|
| `makaron-ui-full` | AeroSpace + SketchyBar + Borders | Hidden (autohide) | Hidden (autohide) |
| `makaron-ui-minimal` | AeroSpace only | Visible | Visible |
| `makaron-ui-stop` | Nothing | Visible | Visible |

- `makaron-ui-helpers` — Shared library (not a command). Contains: `start/stop_aerospace()`, `start/stop_sketchybar()`, `start/stop_borders()`, `switch_aerospace_config()`, `apply_macos_full/minimal_settings()`, `restore_macos_defaults()`, `save/get_ui_mode()`, `reload_current_ui()`.

### Theme Commands
- `makaron-switch-theme <name>` — Core theme switcher (see Theme Switching section)
- `makaron-theme-*` — Shortcuts, each calls `exec makaron-switch-theme <name>`

### System Commands
- `makaron-borders [on|off]` — Toggle or set window borders; persists in `makaron.conf`
- `makaron-update` — Pulls latest code to installed repo (`git reset --hard origin/main`), runs migrations, reloads UI
- `makaron-reinstall` — Removes `~/.local/share/makaron/`, re-clones, re-installs
- `makaron-select-packages` — Re-run optional package selection UI (gum-based)
- `makaron-reload-aerospace-sketchybar` — Reloads AeroSpace + SketchyBar configs, restarts Borders with theme colors
- `makaron-macos-config-reload` — Re-applies macOS settings from `install/macos_settings.sh`
- `makaron-debug` — Diagnostic tool: checks all components, symlinks, configs, migrations
- `makaron-tmux` — Custom tmux session launcher

### Development Commands
- `makaron-dev-generate-ghostty-theme <name>` — Generates Ghostty palette from sketchybar/borders colors
- `makaron-dev-add-migration` — Creates a new timestamped migration script

---

## Theme Switching

### How `makaron-switch-theme` Works (execution order)

1. **Update `current-theme` symlink** — `$MAKARON_PATH/current-theme` points to `themes/<name>/`
2. **Resolve Ghostty theme** — If `ghostty.theme` contains `=` (custom palette), copies to `configs/ghostty/themes/<name>`. If single line (built-in name), uses as-is. Default: "TokyoNight Storm".
3. **Find counterpart theme** — Auto-pairs dark/light variants (`cosmic-dark` <-> `cosmic-light`). Falls back to TokyoNight Storm/Day.
4. **Build Ghostty theme string** — `dark:$ACTIVE_THEME, light:$OPPOSITE_THEME` format
5. **Update shell configs** — Writes `export GHOSTTY_THEME="..."` to `.zshrc` and `.bashrc`
6. **Update Ghostty config** — Sets `theme = ...` in `configs/ghostty/config`
7. **Reload Ghostty** — AppleScript clicks "Reload Configuration" menu item (can't use pgrep from within Ghostty terminal)
8. **Update VSCode/Cursor** — Sets `workbench.colorTheme` and `workbench.preferredDark/LightColorTheme` in main + profile settings.json
9. **Set macOS accent color** — Reads `accent.color`, calls Swift binary (falls back to `defaults write`)
10. **Set macOS appearance** — AppleScript sets dark/light mode
11. **Set wallpaper** — First image from `themes/<name>/backgrounds/` via Finder AppleScript
12. **Reload UI** — Calls `makaron-reload-aerospace-sketchybar` to apply SketchyBar + Borders colors

### The `current-theme` Symlink
`$MAKARON_PATH/current-theme` -> `themes/<name>/` — all plugins read colors from this symlink, so theme changes propagate without restarting processes.

---

## UI Modes Detail

### AeroSpace Gaps Switching
`switch_aerospace_config()` in `makaron-ui-helpers` uses `sed` to update `outer.top` in `~/.aerospace.toml`.
It auto-detects whether the built-in display has a notch via `_has_builtin_notch()` (Swift `NSScreen.safeAreaInsets.top > 0`):
- **Full mode + notch**: `outer.top = [{ monitor."Built-in" = 15 }, 45]` — 45px for SketchyBar, 15px for built-in (notch area absorbs the bar)
- **Full mode + no notch**: `outer.top = 45` — same for all monitors (40px bar + 5px margin)
- **Minimal mode**: `outer.top = 8` — no SketchyBar, just small margin (same for all monitors)

The function resolves the symlink target before editing to modify the actual config file.

### macOS Settings Per Mode
- **Full**: dock autohide, window grouping on (required for AeroSpace), Three Finger Drag off (enables Mission Control), menu bar autohide
- **Minimal**: dock visible, window grouping on, Three Finger Drag off, menu bar visible
- **Stop**: dock visible, window grouping off, Three Finger Drag on (restored)

### Menu Bar Autohide
`_set_menubar_autohide()` uses AppleScript to open System Settings and click the menu bar dropdown (toggle trick: set opposite value first, then target). macOS ignores `defaults write` and `CFPreferences` for this setting — UI click is the only reliable method.

---

## SketchyBar Plugins

### Architecture
Plugins live in `configs/sketchybar/plugins/`. Each plugin follows this pattern:
1. Load theme colors: `source "$THEME_DIR/sketchybar.colors"`
2. Get data (system call, compiled binary, etc.)
3. Update SketchyBar: `sketchybar --set "$NAME" icon="..." label="..." icon.color=$COLOR`

### Color Format
All colors use ARGB hex: `0xffRRGGBB` (ff = fully opaque). Exported as bash variables in theme files.

### Theme Color Variables

`sketchybar.colors` exports:
```bash
# Bar
BAR_COLOR, BAR_BACKGROUND_COLOR
# Items
ICON_COLOR, LABEL_COLOR
# Workspaces (inactive)
SPACE_ICON_COLOR, SPACE_LABEL_COLOR, SPACE_BACKGROUND_COLOR, SPACE_BORDER_COLOR
# Workspaces (focused)
SPACE_FOCUSED_ICON_COLOR, SPACE_FOCUSED_LABEL_COLOR, SPACE_FOCUSED_BACKGROUND_COLOR, SPACE_FOCUSED_BORDER_COLOR
```

`borders.colors` exports:
```bash
ACTIVE_BORDER_COLOR, INACTIVE_BORDER_COLOR, BORDER_WIDTH
```

### Key Plugins
- **aerospace.sh** — Workspace indicator: shows focused state + app icons (Nerd Font). Multi-monitor aware via `$MONITOR` parameter.
- **battery.sh** — Battery status with low-threshold warning from `makaron.conf`
- **memory.sh** — Calls compiled Swift binary `makaron-memory-stats`, shows "X/Y GB"
- **cpu.sh** — Load average from `uptime` divided by core count
- **volume.sh** — Detects Bluetooth vs speakers (caches `system_profiler` result for 5s), different icons
- **display_change.sh** — Reloads SketchyBar when monitor count changes

### SketchyBar Plugin Conventions
- `$NAME` — item name (set by SketchyBar, identifies which item to update)
- `$INFO` — event data (e.g., volume percentage on `volume_change`)
- Events subscribed via: `--subscribe item_name event_name`
- Click handlers: `click_script="aerospace workspace $sid"`

---

## Install Flow

```
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
       |     |-- desktop/ (aerospace, sketchybar, borders, fonts)
       |     |-- terminal/ghostty.sh
       |     └── default theme symlink
       |
       |-- install/packages.sh       # Optional packages:
       |     |-- Fresh install: gum UI per-app selection (6 groups)
       |     └── Update/reinstall: installs from ~/.config/makaron/packages.conf
       |
       |-- macos_settings.sh
       └── migrations.sh
```

**Key detail**: `install.sh` runs `bash "$MAKARON_PATH/install/main.sh"` from file, not piped stdin — this allows interactive `read` prompts and gum UI in install scripts.

### Mandatory vs Optional Packages

**Mandatory** (always installed): Homebrew, Xcode CLT, gum, jq, AeroSpace, SketchyBar, Borders, Nerd Fonts, Ghostty.

**Optional** (user selects per-app via gum UI, grouped into 6 categories):
- Terminal Tools: btop, ffmpeg, fzf, htop, ncdu, tmux, tree, Fresh Editor, Powerlevel10k
- Code Editors: VSCode, Cursor, Sublime Text, Neovim + LazyVim
- AI Tools: ChatGPT, Claude, Gemini CLI, Codex, Claude Code, OpenCode
- Development: Composer, DDEV, gh, lazydocker, lazygit, Node.js, Yarn, pnpm, fnm, Upsun CLI, Bruno, Docker, Sequel Ace, pipx, rbenv
- Desktop Extras: AltTab, Command X, Stats
- Apps: Flameshot, Slack, Spotify, VLC

Selections stored in `~/.config/makaron/packages.conf` (survives update/reinstall). Re-run with `makaron-select-packages`.

---

## Ghostty Config Protection

`configs/ghostty/config` is protected by `git update-index --skip-worktree` so user-specific Ghostty settings survive `makaron-update` (which does `git reset --hard`). The `theme = ...` line in this file is updated by `makaron-switch-theme` via sed.

If `makaron-update` fails with "Entry not uptodate":
```bash
cd ~/.local/share/makaron
git update-index --no-skip-worktree configs/ghostty/config
git add configs/ghostty/config
makaron-update -y
```

---

## Directory Structure

### Repository Layout
```
makaron/
├── bin/                    # User commands (added to PATH)
├── configs/                # Config files (symlinked to ~/.config/)
│   ├── aerospace/
│   ├── sketchybar/plugins/
│   └── ghostty/
├── install/                # Installation scripts
│   ├── all.sh              # Orchestrator: mandatory -> packages -> settings
│   ├── mandatory.sh        # Core components (always installed)
│   ├── packages.sh         # Optional packages: registry, gum UI, installer
│   ├── main.sh             # Main installer (called by install.sh)
│   ├── helpers.sh          # Helper functions (install_cask, install_formula)
│   ├── brew.sh             # Homebrew + CLT setup
│   ├── desktop/            # Desktop environment
│   │   ├── aerospace.sh, borders.sh, sketchybar.sh  # (with config)
│   │   └── fonts.sh
│   ├── development/        # Dev tools
│   │   └── pipx.sh, fnm.sh, rbenv.sh  # (with additional setup)
│   ├── editors/            # Code editors
│   │   └── neovim_lazyvim.sh  # (with LazyVim setup)
│   └── terminal/           # Terminal tools
│       ├── ghostty.sh      # (with config setup)
│       └── p10k.sh         # (with zsh config setup)
├── migrations/             # Timestamped migration scripts
├── src/                    # Swift source files (compiled to bin/)
├── themes/                 # Theme definitions
│   └── <name>/
│       ├── sketchybar.colors
│       ├── borders.colors
│       ├── mode
│       ├── ghostty.theme    # Built-in name or custom palette
│       ├── vscode.theme     # (optional) VSCode/Cursor color theme
│       ├── accent.color     # (optional) macOS accent color (-1..6)
│       └── backgrounds/
└── install.sh              # Bootstrap (clone + call main.sh)
```

### User System Layout
```
$HOME/
├── .local/share/makaron/           # Clone of repo
│   └── current-theme -> themes/X   # Active theme symlink
├── .local/state/makaron/migrations/ # Migration state
├── .config/makaron/
│   ├── makaron.conf                # User settings
│   └── packages.conf              # Optional package selections
├── .config/sketchybar -> ...       # Symlink
├── .config/ghostty -> ...          # Symlink
└── .aerospace.toml -> ...          # Symlink
```

### Key Paths
```bash
MAKARON_PATH="$HOME/.local/share/makaron"
MAKARON_MIGRATIONS_STATE_PATH="$HOME/.local/state/makaron/migrations"
MAKARON_CONF="$HOME/.config/makaron/makaron.conf"
MAKARON_PACKAGES_CONF="$HOME/.config/makaron/packages.conf"
```

### Development vs Installed Repo
- **Dev repo**: your local clone — where you edit code
- **Installed repo**: `~/.local/share/makaron/` — separate clone, symlinked to `~/.config/`

For quick testing you can modify files directly in `~/.local/share/makaron/`, but **revert those changes before running `makaron-update`** — it does `git reset --hard origin/main` and will fail if there are untracked/conflicting changes (except `configs/ghostty/config` which is protected by skip-worktree).

---

## User Configuration

### Overview
User-specific settings stored outside the repo in `~/.config/makaron/makaron.conf`.

### How It Works
- Template: `templates/makaron.conf.default`
- User file: `~/.config/makaron/makaron.conf`
- On install: template is copied to user location
- On update: missing variables are appended (existing values preserved)

### Adding New Config Variables
1. Add variable to `templates/makaron.conf.default`
2. Use in scripts: `source "$HOME/.config/makaron/makaron.conf"`
3. Always provide fallback: `VARIABLE="${VARIABLE:-default_value}"`

### Current Variables
```bash
BATTERY_LOW_THRESHOLD=20  # Battery warning threshold (%)
BORDERS_ENABLED=true      # Window borders (JankyBorders) — false to disable
```

---

## Migration System

### Overview
Database-style migrations for safe, incremental config updates.

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
makaron-migration-status  # Show status
makaron-dev-add-migration # Create new migration
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

---

## Adding a New Theme

1. Create `themes/<name>/` with:
   - `borders.colors`
   - `sketchybar.colors`
   - `mode` (dark/light)
   - `ghostty.theme` (see below)
   - `vscode.theme` (optional, see below)
   - `accent.color` (optional) — single line with macOS accent color value (-1=graphite, 0=red, 1=orange, 2=yellow, 3=green, 4=blue, 5=purple, 6=pink)
   - `backgrounds/` dir with wallpaper

2. Create executable `bin/makaron-theme-<name>`:
```bash
#!/bin/bash
exec makaron-switch-theme <name>
```

3. Create `ghostty.theme` — either a **built-in theme name** or a **custom palette**:

   **Built-in** (single line, no `=`):
   ```
   TokyoNight Storm
   ```
   Available: Nord, Catppuccin Mocha/Latte, TokyoNight Storm/Day, Gruvbox Dark/Light, Everforest Dark Hard/Light Med, Kanagawa Dragon, Rose Pine/Dawn/Moon, Flexoki Light.

   **Custom palette** (multiple lines with `=`):
   ```
   background = #0f2838
   foreground = #c5d5dd
   cursor-color = #5a8ba8
   selection-background = #1e3d52
   selection-foreground = #c5d5dd
   palette = 0=#0a1b27
   ...
   palette = 15=#f9fbfb
   ```
   Custom palettes are auto-installed to `configs/ghostty/themes/<name>` during theme switch.
   Use `makaron-dev-generate-ghostty-theme <name>` to generate a starting palette from sketchybar/borders colors.

   **Dark/light counterparts**: The script auto-discovers pairs (e.g., `cosmic-dark` ↔ `cosmic-light`).

4. Create `vscode.theme` (optional) — a single line with the exact VSCode color theme name:
   ```
   Tokyo Night Storm
   ```
   Sets `workbench.colorTheme` in both VSCode and Cursor `settings.json` (including profiles).
   If the file doesn't exist or `settings.json` is missing, the editor is silently skipped.

5. If custom palette: copy the file to `configs/ghostty/themes/<name>` and commit it.

6. Update `README.md` with theme name and command.

---

## Editor Profiles

### Overview
Pre-configured profiles for VSCode and Cursor with settings, extensions, and keybindings.

### Structure
```
profiles/
└── <profile-name>/
    ├── settings.json      # Editor settings
    ├── extensions.txt     # Extension IDs (one per line, # for comments)
    └── keybindings.json   # Custom keybindings (optional)
```

### Paths
```bash
# VSCode
~/Library/Application Support/Code/User/settings.json
~/Library/Application Support/Code/User/keybindings.json

# Cursor
~/Library/Application Support/Cursor/User/settings.json
~/Library/Application Support/Cursor/User/keybindings.json
```

### Usage
```bash
makaron-apply-editor-profile <profile-name> [--cursor-only|--vscode-only]
```

### Creating New Profile
1. Create `profiles/<name>/` directory
2. Add `settings.json` with editor settings
3. Add `extensions.txt` with extension IDs
4. Optionally add `keybindings.json`
5. Update `README.md`

---

## AeroSpace + SketchyBar Integration

### Critical Config
In `configs/aerospace/.aerospace.toml`:
```toml
exec-on-workspace-change = ['/bin/bash', '-c',
    'sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE'
]
```
**Required** - without this, empty workspaces won't highlight correctly.

### Plugin Logic (`aerospace.sh`)
```bash
# Multi-monitor: use --monitor --visible
if [[ -n "$MONITOR" ]]; then
  IS_FOCUSED=$(aerospace list-workspaces --monitor "$MONITOR" --visible 2>/dev/null)
else
  # Single monitor: use env var with fallback
  if [[ -z "$FOCUSED_WORKSPACE" ]]; then
    FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null)
  fi
  IS_FOCUSED="$FOCUSED_WORKSPACE"
fi
```

### Monitor Detection
- Single monitor: Show all workspaces on one bar
- Multi-monitor: Each bar shows only its assigned workspaces
- Auto-reload on monitor connect/disconnect via `display_change.sh`

### Known Issue
`aerospace list-workspaces --focused` fails for empty workspaces - returns last non-empty workspace. Solution: Use event-driven `$FOCUSED_WORKSPACE` from callback.

---

## Troubleshooting

### Diagnostics Tool
Use `makaron-debug` to check system status:
- Shows all component statuses (AeroSpace, SketchyBar, Borders, Ghostty)
- Verifies symlinks and configs
- Checks migration status
- Useful when debugging issues or verifying installation

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
