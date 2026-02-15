# AGENTS.md

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
```

- Source files: `src/*.swift`
- Compiled binaries: `bin/` (gitignored)
- Compilation runs automatically during `install/desktop/sketchybar.sh`

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
│   ├── all.sh              # Sources all category scripts
│   ├── main.sh             # Main installer (called by install.sh)
│   ├── helpers.sh          # Helper functions (install_cask, install_formula)
│   ├── brew.sh             # Homebrew + CLT setup
│   ├── ai/all.sh           # AI tools
│   ├── apps/all.sh         # General apps
│   ├── desktop/            # Desktop environment
│   │   ├── all.sh
│   │   ├── aerospace.sh, borders.sh, sketchybar.sh  # (with config)
│   │   └── fonts.sh
│   ├── development/        # Dev tools
│   │   ├── all.sh
│   │   └── pipx.sh, rbenv.sh  # (with additional setup)
│   ├── editors/            # Code editors
│   │   ├── all.sh
│   │   └── neovim_lazyvim.sh  # (with LazyVim setup)
│   └── terminal/           # Terminal tools
│       ├── all.sh
│       └── ghostty.sh      # (with config setup)
├── migrations/             # Timestamped migration scripts
├── src/                    # Swift source files (compiled to bin/)
├── themes/                 # Theme definitions
│   └── <name>/
│       ├── sketchybar.colors
│       ├── borders.colors
│       ├── mode
│       └── backgrounds/
└── install.sh              # Bootstrap (clone + call main.sh)
```

### User System Layout
```
$HOME/
├── .local/share/makaron/           # Clone of repo
│   └── current-theme -> themes/X   # Active theme symlink
├── .local/state/makaron/migrations/ # Migration state
├── .config/sketchybar -> ...       # Symlink
├── .config/ghostty -> ...          # Symlink
└── .aerospace.toml -> ...          # Symlink
```

### Key Paths
```bash
MAKARON_PATH="$HOME/.local/share/makaron"
MAKARON_MIGRATIONS_STATE_PATH="$HOME/.local/state/makaron/migrations"
MAKARON_CONF="$HOME/.config/makaron/makaron.conf"
```

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
   - `backgrounds/` dir with wallpaper

2. Create executable `bin/makaron-theme-<name>`:
```bash
#!/bin/bash
exec makaron-switch-theme <name>
```

3. Add Ghostty theme mapping in `bin/makaron-switch-theme` function `get_ghostty_theme_mapping()`:
```bash
        <theme-name>)
            echo "Ghostty Dark Theme|Ghostty Light Theme"
            ;;
```
   Available Ghostty themes: Nord, Catppuccin Mocha/Latte, TokyoNight Storm/Day, Gruvbox Dark/Light, Everforest, Kanagawa, Rosé Pine, Flexoki Light.

4. Update `README.md` with theme name and command.

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
