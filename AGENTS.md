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
│   ├── ai/, apps/, desktop/, development/, editors/, terminal/
│   └── migrations.sh
├── migrations/             # Timestamped migration scripts
├── themes/                 # Theme definitions
│   └── <name>/
│       ├── sketchybar.colors
│       ├── borders.colors
│       ├── mode
│       └── backgrounds/
└── install.sh
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

3. Update `README.md` with theme name and command.

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
