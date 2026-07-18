# Makaron - macOS Developer Configuration

> **Why "Makaron"?** The name comes from the Polish word for "pasta", which sounds similar to "Mac" at the beginning - a playful nod to macOS while keeping a Polish identity.

Complete macOS development environment for PHP and Drupal developers with AeroSpace window management, a SketchyBar top status bar, Ghostty, and optional productivity tools.

> [!IMPORTANT]
> **Use this as a starting point, not a finished product.** Makaron is a personal, opinionated setup that changes frequently - widgets get added, removed, or rewired, defaults are tweaked, and breaking changes can land between updates. The best way to use it is to **fork the repository**, install from your own fork, and adjust it to fit your own workflow.

## Perfect For

- **PHP Developers** - Optimized workflow for PHP development
- **Drupal Developers** - Tailored environment for Drupal projects
- **macOS Power Users** - Tiling window management with a compact custom top bar
- **Terminal Users** - Ghostty, shell tools, and optional AI CLIs

## Requirements

- macOS
- Internet connection
- Admin access for Homebrew packages and system settings

## Quick Installation

```bash
curl -sL https://raw.githubusercontent.com/grzegorzbartman/makaron/main/install.sh | bash
```

After installation, reload your shell or open a new terminal.

## What Gets Installed

### UI & Window Management
- **AeroSpace** - Modern tiling window manager
- **SketchyBar** - Custom top status bar
- **Nerd Fonts** - Developer-friendly fonts with icon support

### Productivity Tools
- **Ghostty** - Fast, modern terminal emulator (configuration stays user-managed)
- **cmux** - Optional Ghostty-based terminal with vertical tabs and AI agent notifications
- **Slack** - Team communication
- **Stats** - System monitor in menu bar
- **btop** - System resource monitor
- **Neovim** - Modern Vim-based text editor
- **Upsun CLI** - Upsun command-line tool

### AI Tools
- **Claude** - AI assistant desktop app
- **Claude Code** - AI coding assistant
- **Gemini CLI** - AI assistant command-line tool
- **Cursor** - AI-powered code editor
- **ChatGPT** - AI assistant desktop app
- **Codex** - AI code assistant
- **OpenCode** - AI coding assistant CLI

### Development Tools
- **Bruno** - Open-source API client
- **Docker Desktop** - Container platform
- **DDEV** - Local PHP development environment
- **PhpStorm** - Professional PHP IDE
- **Sequel Ace** - MySQL/MariaDB database management
- **VSCode** - Popular code editor
- **Composer** - PHP dependency manager
- **LazyDocker** - Terminal UI for Docker
- **LazyGit** - Terminal UI for Git
- **Node.js** - JavaScript runtime
- **pipx** - Python application installer
- **rbenv** - Ruby version manager

### System Configuration
- **macOS Settings** - Optimized system preferences for development workflow
- **Migration System** - Safe, incremental configuration updates
- **User Config** - Personal settings in `~/.config/makaron/makaron.conf`

## Manual Installation

```bash
cd ~/projects
git clone https://github.com/grzegorzbartman/makaron.git
cd makaron
./install.sh
```

## Updates

To update your installation to the latest version:

```bash
makaron-update
```

This command will:
- Pull the latest changes from GitHub
- Run any pending migrations
- Reload configurations for the current UI mode

## Usage

### Available Commands

- **`makaron-update`** - Update configuration to latest version
- **`makaron-reload-aerospace-sketchybar`** - Reload AeroSpace + SketchyBar and re-apply layout
- **`makaron-reinstall`** - Complete reinstall from scratch
- **`makaron-migrate`** - Run pending migrations
- **`makaron-doctor`** - Concise health check with optional safe repairs (`--fix`, `--json`)
- **`makaron-ui-full`** - Start full UI (AeroSpace + SketchyBar, hidden Dock/menu bar)
- **`makaron-ui-stop`** - Stop UI components
- **`makaron-macos-config-reload`** - Apply macOS settings

### UI Modes

| Command | Components | Dock | Menu Bar | Layout |
|---|---|---|---|---|
| `makaron-ui-full` | AeroSpace + SketchyBar | Hidden | Hidden | gaps `0`, top reserve `40` |
| `makaron-ui-stop` | Nothing | Hidden | Visible | UI state not applied |

The SketchyBar height is `40px`. AeroSpace windows are edge-to-edge except for that top reserve in full mode.

### Manual Commands

- **Reload config**: `makaron-reload-aerospace-sketchybar`
- **macOS settings**: `makaron-macos-config-reload`

## Troubleshooting

If you encounter issues with your installation:

- **Quick health check**: `makaron-doctor`
- **Safe automatic repairs**: `makaron-doctor --fix`
- **Complete reinstall**: `makaron-reinstall`
- **Manual migration**: `makaron-migrate`

### Common Issues After Fresh Installation

**Problem: Commands `makaron-*` are not available in terminal**

After installation, reload your shell:

```bash
source ~/.zshrc
```

Or restart your terminal completely. If commands still do not work:

```bash
echo $PATH | grep makaron
echo 'export PATH="$HOME/.local/share/makaron/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**Problem: Top bar or menu bar settings are wrong**

Makaron switches the menu bar through UI mode helpers:

```bash
makaron-ui-full
makaron-reload-aerospace-sketchybar
```

If macOS blocks the menu bar UI automation, open **System Settings > Control Center > Menu Bar** and set it manually.

**Problem: AeroSpace workspaces are not highlighted correctly**

Reload AeroSpace and SketchyBar:

```bash
aerospace reload-config
makaron-reload-aerospace-sketchybar
```

**Problem: Wrong workspaces after monitor changes**

```bash
sketchybar --reload
makaron-reload-aerospace-sketchybar
```

## Keyboard Shortcuts

Keyboard shortcuts are configured in `configs/aerospace/.aerospace.toml`.

Common defaults include:
- `alt-h/j/k/l` - Focus windows
- `alt-shift-h/j/k/l` - Move windows
- `alt-1..9` - Switch workspaces
- `alt-shift-1..9` - Move window to workspace
- `alt-f` - Toggle fullscreen

Review the AeroSpace config for the full list.

## Modular Installation

The installation is modular. Core install flow:

```text
install/
├── all.sh              # Main orchestrator
├── mandatory.sh        # Core requirements
├── packages.sh         # Optional package selector
├── brew.sh             # Homebrew setup
├── desktop/            # AeroSpace, SketchyBar, fonts
├── terminal/           # Ghostty and terminal helpers
├── editors/            # Editor application installers
├── development/        # Languages, frameworks, dev tools
├── apps/               # GUI applications
└── macos_settings.sh
```

## Files

- `configs/aerospace/.aerospace.toml` - AeroSpace config
- `configs/sketchybar/colors.sh` - Static SketchyBar colors
- `configs/sketchybar/sketchybarrc` - SketchyBar status bar config
- `configs/sketchybar/plugins/` - SketchyBar plugin scripts
- `install/` - Modular installation scripts
- `migrations/` - Database-style migrations for configuration updates
- `templates/makaron.conf.default` - Default user configuration template
- `bin/` - Executable scripts

## Migration System

Makaron includes a migration system similar to database migrations. This allows safe, incremental updates to your configuration.

### How It Works

- Migrations are timestamped shell scripts in `migrations/`
- Each migration runs only once per installation
- State is tracked in `~/.local/state/makaron/migrations/`
- Migrations run automatically during `makaron-update`

### Creating Migrations

Create a new timestamped shell script in `migrations/` and make it executable:

```bash
chmod +x migrations/TIMESTAMP.sh
```

### Manual Migration

```bash
makaron-migrate
```

## User Configuration

Personal settings are stored in `~/.config/makaron/makaron.conf`. This file is created on install and preserved during updates. New variables added later get appended on update; existing values are never overwritten.

Available settings:

```bash
BATTERY_LOW_THRESHOLD=20                # Battery warning threshold (%)
SKETCHYBAR_COMPACT_MODE=false           # Hide CPU/memory/storage widgets on the right side
SKETCHYBAR_HIDE_EMPTY_WORKSPACES=false  # Hide empty, non-focused workspaces in the bar
```

## Contributing

Contributions are welcome:

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a pull request

Please read [AGENTS.md](AGENTS.md) for development guidelines and code style.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
