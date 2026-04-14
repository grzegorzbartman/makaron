# AGENTS.md

## What Is Makaron

Makaron is a macOS desktop environment manager. It sets up and orchestrates a tiling window manager (AeroSpace), a native menu bar app (MakaronBar), and a terminal (Ghostty).

The project is a collection of bash scripts, config files, and Swift binaries. It installs via a single `curl | bash` command and updates itself via `makaron-update`.

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
# Compile Swift sources
swiftc -O -o bin/makaron-memory-stats src/memory_stats.swift

# MakaronBar (multi-file Swift project)
swiftc -O -o bin/makaron-bar src/makaron_bar/*.swift -framework Cocoa -framework IOKit
```

- Source files: `src/*.swift`, `src/makaron_bar/*.swift`
- Compiled binaries: `bin/` (gitignored)
- Compilation runs automatically during `install/desktop/makaron-bar.sh`

### Why Swift
- `memory_stats.swift` — Uses Mach `host_statistics64` API to match Activity Monitor exactly. Shell-based alternatives (`vm_stat`, `top`) give inaccurate numbers.
- `makaron_bar/` — Native macOS menu bar app using AppKit. Displays AeroSpace workspaces, system info, and quick actions in the menu bar.


---

## User Commands (`bin/`)

All commands are in `bin/` and added to `$PATH` during install.

### System Commands
- `makaron-timer [status|recent|start|stop|toggle]` — Timewarrior wrapper used by the MakaronBar timer panel
- `makaron-update` — Pulls latest code to installed repo (`git reset --hard origin/main`), runs migrations, reloads UI
- `makaron-reinstall` — Removes `~/.local/share/makaron/`, re-clones, re-installs
- `makaron-select-packages` — Re-run optional package selection UI (gum-based)
- `makaron-reload` — Reloads AeroSpace config + restarts MakaronBar
- `makaron-macos-config-reload` — Re-applies macOS settings from `install/macos_settings.sh`
- `makaron-debug` — Diagnostic tool: checks all components, symlinks, configs, migrations
- `makaron-tmux` — Custom tmux session launcher
- `makaron-tools` — Quick actions (e.g., new Apple Note with workspace restore)

### Development Commands
- `makaron-dev-add-migration` — Creates a new timestamped migration script

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
       |     |-- desktop/ (aerospace, makaron-bar, fonts)
       |     └── terminal/ghostty.sh
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

**Mandatory** (always installed): Homebrew, Xcode CLT, gum, jq, AeroSpace, MakaronBar, Nerd Fonts, Ghostty, Timewarrior.

**Optional** (user selects per-app via gum UI, grouped into 6 categories):
- Terminal Tools: btop, ffmpeg, fzf, htop, ncdu, tmux, tree, Fresh Editor, Powerlevel10k
- Code Editors: VSCode, Cursor, Sublime Text, Neovim + LazyVim
- AI Tools: ChatGPT, Claude, Gemini CLI, Codex, Claude Code, OpenCode
- Development: Composer, DDEV, gh, lazydocker, lazygit, Node.js, Yarn, pnpm, fnm, Upsun CLI, Bruno, Docker, Sequel Ace, pipx, rbenv
- Desktop Extras: Command X, Stats
- Apps: Todoist, Flameshot, Slack, Spotify, VLC

Selections stored in `~/.config/makaron/packages.conf` (survives update/reinstall). Re-run with `makaron-select-packages`.

---

## Ghostty Config Protection

`configs/ghostty/config` is protected by `git update-index --skip-worktree` so user-specific Ghostty settings survive `makaron-update` (which does `git reset --hard`).

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
│   ├── makaron-bar         # Compiled MakaronBar binary (gitignored)
│   ├── makaron-tools       # Quick actions script
│   └── ...
├── configs/                # Config files (symlinked to ~/.config/)
│   ├── aerospace/
│   └── ghostty/
├── install/                # Installation scripts
│   ├── all.sh              # Orchestrator: mandatory -> packages -> settings
│   ├── mandatory.sh        # Core components (always installed)
│   ├── packages.sh         # Optional packages: registry, gum UI, installer
│   ├── main.sh             # Main installer (called by install.sh)
│   ├── helpers.sh          # Helper functions (install_cask, install_formula)
│   ├── brew.sh             # Homebrew + CLT setup
│   ├── desktop/            # Desktop environment
│   │   ├── aerospace.sh, makaron-bar.sh  # (with config)
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
│   ├── memory_stats.swift
│   └── makaron_bar/        # MakaronBar multi-file Swift project
└── install.sh              # Bootstrap (clone + call main.sh)
```

### User System Layout
```
$HOME/
├── .local/share/makaron/           # Clone of repo
├── .local/state/makaron/migrations/ # Migration state
├── .config/makaron/
│   ├── makaron.conf                # User settings
│   └── packages.conf              # Optional package selections
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
BATTERY_LOW_THRESHOLD=20                # Battery warning threshold (%)
MAKARON_TIMER_TAGS="sales,marketing,…"  # Comma-separated tags shown in timer panel
MAKARON_TIMER_DEFAULT_TAG=other         # Default tag for makaron-timer start/toggle
MAKARON_TIMER_RECENT_COUNT=4            # Recent entries shown in timer panel
MAKARON_NOTES_ENABLED=false             # Apple Notes quick action in MakaronBar panel
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

## AeroSpace + MakaronBar Integration

### Workspace Change Notification
In `configs/aerospace/.aerospace.toml`:
```toml
exec-on-workspace-change = ['/bin/bash', '-c',
    'echo "$AEROSPACE_FOCUSED_WORKSPACE" > /tmp/makaron_focused_ws'
]
```
MakaronBar watches this file to update the active workspace indicator.

### Monitor Detection
- Single monitor: Show all workspaces in one strip
- Multi-monitor: Each display shows its assigned workspaces
- Auto-reload on monitor connect/disconnect

---

## Troubleshooting

### Diagnostics Tool
Use `makaron-debug` to check system status:
- Shows all component statuses (AeroSpace, MakaronBar, Ghostty)
- Verifies symlinks and configs
- Checks migration status
- Useful when debugging issues or verifying installation

### Migration Not Running
```bash
ls ~/.local/state/makaron/migrations/  # Check if marked completed
rm ~/.local/state/makaron/migrations/TIMESTAMP.sh  # Remove to re-run
makaron-migrate
```

### makaron-update Fails (Entry not uptodate / Local changes)
If update fails due to git state, re-run the install script (it fetches latest and fixes skip-worktree):
```bash
curl -sL https://raw.githubusercontent.com/grzegorzbartman/makaron/main/install.sh | bash
```
Then use `makaron-update` or `makaron-update -y` for future updates.
