# Makaron - macOS Developer Configuration

![Makaron Screenshot](docs/makaron-01.png)

> **Why "Makaron"?** The name comes from the Polish word for "pasta" 🍝, which sounds similar to "Mac" at the beginning - a playful nod to macOS while keeping a Polish identity.

Complete macOS development environment for PHP and Drupal developers with modern window management, terminal, and productivity tools.

## Perfect for

- **PHP Developers** - Optimized workflow for PHP development
- **Drupal Developers** - Tailored environment for Drupal projects
- **Web Developers** - Modern tools and efficient window management
- **Terminal Users** - Enhanced terminal experience with Ghostty
- **Productivity Enthusiasts** - Clean, distraction-free development setup

## Requirements

- macOS (tested on macOS 26)
- Homebrew installed
- Git

## Quick Installation

Install everything with one command:

```bash
curl -sL https://raw.githubusercontent.com/grzegorzbartman/makaron/main/install.sh | bash
```

This will:
- Clone the repository to `~/.local/share/makaron`
- Install Homebrew package manager
- Set up modern development environment (AeroSpace, SketchyBar, Ghostty)
- Configure system settings for optimal development workflow
- Install developer fonts and tools

## What Gets Installed

### UI & Window Management
- **AeroSpace** - Modern tiling window manager
- **SketchyBar** - Custom status bar
- **Borders** - Visual window borders
- **Nerd Fonts** - Developer-friendly fonts with icon support
### AI Tools
- **Claude** - AI assistant desktop app
- **Claude Code** - AI coding assistant
- **Gemini CLI** - AI assistant command-line tool
- **Cursor** - AI-powered code editor
- **ChatGPT** - AI assistant desktop app
- **Codex** - AI code assistant
- **OpenCode** - AI coding assistant CLI

### Development Tools
- **Bruno** - Open-source API client (Postman alternative)
- **Docker Desktop** - Container platform
- **DDEV** - Local PHP development environment
- **PhpStorm** - Professional PHP IDE
- **Sequel Ace** - MySQL/MariaDB database management
- **VSCode** - Popular code editor
- **Composer** - PHP dependency manager
- **LazyDocker** - Terminal UI for Docker
- **LazyGit** - Terminal UI for Git
- **Node.js** - JavaScript runtime (includes Yarn)
- **pipx** - Python application installer
- **rbenv** - Ruby version manager

### Productivity Tools
- **Ghostty** - Fast, modern terminal emulator
- **Alt-Tab** - Windows-style alt-tab for macOS
- **Slack** - Team communication
- **Stats** - System monitor in menu bar
- **btop** - System resource monitor
- **Neovim** - Modern Vim-based text editor
- **Upsun CLI** - Upsun (Platform.sh) command-line tool
- **tmux** - Terminal multiplexer

### System Configuration
- **macOS Settings** - Optimized system preferences for development workflow
- **Migration System** - Safe, incremental configuration updates
- **User Config** - Personal settings in `~/.config/makaron/makaron.conf`

## Manual Installation

If you prefer manual installation:

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
- Reload all configurations

## Usage

### Available Commands

After installation, you'll have access to these commands:

- **`makaron-update`** - Update configuration to latest version
- **`makaron-reload-aerospace-sketchybar`** - Reload all configurations (AeroSpace, SketchyBar)
- **`makaron-reinstall`** - Complete reinstall from scratch
- **`makaron-migrate`** - Run pending migrations
- **`makaron-migration-status`** - Show migration status
- **`makaron-dev-add-migration`** - Create new migration (development)
- **`makaron-debug`** - Diagnose system status
- **`makaron-ui-start`** - Start UI components (AeroSpace, SketchyBar, Borders)
- **`makaron-ui-stop`** - Stop UI components
- **`makaron-macos-config-reload`** - Apply macOS settings
- **`makaron-apply-editor-profile`** - Apply VSCode/Cursor profile
- **`makaron-theme-*`** - Switch themes (see Themes section below)

### Themes

Makaron includes twenty-five beautiful themes that change the colors of your UI and wallpaper (some inspired by [Omarchy](https://github.com/basecamp/omarchy), some featuring wallpapers from [Basic Apple Guy](https://basicappleguy.com), COSMIC themes inspired by [System76 COSMIC](https://system76.com/cosmic), and Ubuntu themes with official Ubuntu 25.10 wallpapers):

<p align="center">
  <img src="docs/makaron-02.png" alt="Catppuccin Latte" width="49%" />
  <img src="docs/makaron-05.png" alt="Flexoki Light" width="49%" />
</p>

<p align="center">
  <img src="docs/makaron-03.png" alt="Matte Black" width="32%" />
  <img src="docs/makaron-04.png" alt="Everforest" width="32%" />
  <img src="docs/makaron-01.png" alt="Tokyo Night" width="32%" />
</p>

1. **Tokyo Night** (default) - Dark theme with purple/blue accents
2. **Catppuccin** - Dark theme with pastel colors
3. **Catppuccin Latte** - Light theme for daytime use
4. **Catppuccin Mocha Dark** - Dark theme with mocha colors
5. **Droptica Dark** - Dark theme with Droptica branding
6. **Ethereal** - Dreamy, soft dark theme
7. **Everforest** - Dark theme with green forest colors
8. **Flexoki Light** - Light theme with modern colors
9. **Gruvbox** - Dark theme with warm retro colors
10. **Hackerman** - Cyberpunk/Matrix inspired theme
11. **Kanagawa** - Dark theme inspired by Japanese art
12. **Matte Black** - Minimalist dark theme
13. **Nord** - Cool arctic-inspired color palette
14. **Osaka Jade** - Dark theme with jade green accents
15. **Ristretto** - Warm dark theme with coffee tones
16. **Rose Pine** - Dark theme with rose and pine colors
17. **Underwater Dark** - Deep ocean dark theme
18. **Underwater Light** - Ocean-inspired light theme
19. **Verdant Dark** - Lush green dark theme
20. **Verdant Light** - Fresh green light theme
21. **COSMIC Dark** - Pop!_OS COSMIC-inspired dark theme with teal accents
22. **COSMIC Light** - Pop!_OS COSMIC-inspired light theme with teal accents
23. **Ubuntu Dark** - Official Ubuntu dark theme with aubergine colors
24. **Ubuntu Light** - Official Ubuntu light theme
25. **Miasma** - Dark organic theme with olive green accents

Switch themes instantly with:

```bash
makaron-theme-tokyo-night           # Dark purple/blue
makaron-theme-catppuccin            # Dark pastel
makaron-theme-catppuccin-latte      # Light pastel
makaron-theme-catppuccin-mocha-dark # Dark mocha
makaron-theme-droptica-dark         # Dark Droptica
makaron-theme-ethereal              # Dreamy dark
makaron-theme-everforest            # Dark forest green
makaron-theme-flexoki-light         # Light modern
makaron-theme-gruvbox               # Dark retro warm
makaron-theme-hackerman             # Cyberpunk/Matrix
makaron-theme-kanagawa              # Dark Japanese art
makaron-theme-matte-black           # Minimalist dark
makaron-theme-nord                  # Cool arctic
makaron-theme-osaka-jade            # Dark jade green
makaron-theme-ristretto             # Dark coffee warm
makaron-theme-rose-pine             # Dark rose/pine
makaron-theme-underwater-dark       # Deep ocean dark
makaron-theme-underwater-light      # Ocean light
makaron-theme-verdant-dark          # Lush green dark
makaron-theme-verdant-light         # Fresh green light
makaron-theme-cosmic-dark           # COSMIC teal dark
makaron-theme-cosmic-light          # COSMIC teal light
makaron-theme-ubuntu-dark           # Ubuntu aubergine dark
makaron-theme-ubuntu-light          # Ubuntu light
makaron-theme-miasma                # Dark organic olive
```

Each theme includes:
- Custom color scheme for SketchyBar
- Matching window border colors
- Coordinated desktop wallpaper

### Editor Profiles

Makaron includes pre-configured profiles for VSCode and Cursor:

```bash
# Apply to both Cursor and VSCode
makaron-apply-editor-profile development-php-drupal

# Apply to Cursor only
makaron-apply-editor-profile development-php-drupal --cursor-only

# Apply to VSCode only
makaron-apply-editor-profile development-php-drupal --vscode-only
```

**Available profiles:**
- **`development-php-drupal`** - PHP/Drupal development with auto dark/light theme, PHP Intelephense, Xdebug, DDEV Manager, Twig support, Drupal file associations

### Manual Commands

- **Reload config**: `makaron-reload-aerospace-sketchybar`
- **macOS settings**: `makaron-macos-config-reload`

### Troubleshooting

If you encounter issues with your installation:

- **Complete reinstall**: `makaron-reinstall` - Removes everything and reinstalls from scratch
- **Check migration status**: `makaron-migration-status` - See which migrations have been applied
- **Manual migration**: `makaron-migrate` - Run pending migrations manually

#### Common Issues After Fresh Installation

**Problem: Commands `makaron-*` are not available in terminal**

After installation, you need to reload your shell to make the commands available:

```bash
# Option 1: Reload your shell configuration
source ~/.zshrc

# Option 2: Restart your terminal completely
# Close and reopen your terminal application
```

The install script adds `~/.local/share/makaron/bin` to your PATH in `~/.zshrc` and `~/.bashrc`. If commands still don't work after reloading:

```bash
# Verify PATH is correct
echo $PATH | grep makaron

# If not found, manually add to your shell config
echo 'export PATH="$HOME/.local/share/makaron/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**Problem: Top bar (menu bar) is not auto-hiding**

The menu bar autohide is configured through macOS settings. To enable it:

```bash
# Run the macOS settings script
~/.local/share/makaron/install/macos_settings.sh

# Then restart SystemUIServer to apply changes
killall SystemUIServer
```

Alternatively, enable it manually:
1. Open **System Settings**
2. Go to **Desktop & Dock**
3. Enable **Automatically hide and show the menu bar**

**Note**: On some macOS versions, you might need to log out and log back in for the menu bar autohide to take effect.

**Problem: `makaron-update` fails with "configs/ghostty/config not uptodate, cannot merge"**

This happens after switching themes — ghostty config gets modified locally and goes out of sync with git index. Run this once to fix:

```bash
cd ~/.local/share/makaron && git update-index --no-skip-worktree configs/ghostty/config && git add configs/ghostty/config && makaron-update -y
```

---

**Problem: SketchyBar or AeroSpace not working properly**

Try reloading the configuration:

```bash
makaron-reload-aerospace-sketchybar
```

If that doesn't help, check if the services are running:

```bash
# Check if AeroSpace is running
pgrep -x "AeroSpace" || open -a AeroSpace

# Check if SketchyBar is running
pgrep -x "sketchybar" || brew services restart sketchybar
```

## Keyboard Shortcuts

**Window Management:**
- `Ctrl+Alt+Left/Down/Up/Right` - Focus window (left/down/up/right)
- `Alt+Shift+Left/Down/Up/Right` - Move window (left/down/up/right)
- `Alt+Minus/Equal` - Resize window (decrease/increase)
- `Alt+Slash` - Toggle horizontal/vertical tiles layout
- `Alt+Comma` - Toggle horizontal/vertical accordion layout
- `Alt+F` - Toggle floating/tiling mode
- `Alt+Shift+Semicolon` - Enter service mode

**Workspaces:**
- `Alt+1-9/0` - Switch to workspace 1-10
- `Alt+Q/W` - Switch to workspace Q/W
- `Alt+Shift+1-9/0` - Move window to workspace 1-10
- `Alt+Shift+Q/W` - Move window to workspace Q/W
- `Alt+Left/Right` - Switch to previous/next workspace
- `Cmd+Alt+Left/Right` - Move window to previous/next workspace

**Multi-Monitor:**
- `Ctrl+Tab` - Focus next monitor
- `Ctrl+Shift+Tab` - Focus previous monitor
- `Ctrl+Alt+Shift+Left/Right` - Move window to left/right monitor
- `Ctrl+Alt+Shift+1/2` - Move window to monitor 1/2

**Service Mode:**
- `Alt+Shift+Semicolon` - Enter service mode
- `Esc` - Exit service mode and reload config
- `R` - Reset layout (flatten workspace tree)
- `F` - Toggle floating/tiling mode
- `Backspace` - Close all windows except current
- `Alt+Shift+H/J/K/L` - Join with adjacent window (left/down/up/right)
- `Up/Down` - Volume up/down
- `Shift+Down` - Mute volume (set to 0)

**Quick Apps:**
- `Ctrl+Alt+B` - Safari
- `Ctrl+Alt+C` - Cursor
- `Ctrl+Alt+T` - Ghostty
- `Ctrl+Alt+P` - PhpStorm
- `Ctrl+Alt+Z` - Todoist
- `Ctrl+Alt+N` - Notes (new note)
- `Ctrl+Alt+M` - Mimestream

## Modular Installation

All installation scripts are modular and organized in the `install/` directory:

```
install/
├── ai/           # AI tools (Claude Code, ChatGPT, Cursor)
├── desktop/      # Window manager, status bar, system UI
├── terminal/     # Terminal emulators and CLI utilities
├── editors/      # IDEs and text editors
├── development/  # Languages, frameworks, dev tools
├── apps/         # GUI applications
└── macos_settings.sh
```

You can customize your installation by modifying which scripts run in `install/all.sh`, or run individual installation scripts directly.

## Files

- `configs/aerospace/.aerospace.toml` - AeroSpace config
- `configs/ghostty/config` - Ghostty terminal config
- `configs/sketchybar/sketchybarrc` - SketchyBar status bar config
- `profiles/` - Editor profiles for VSCode/Cursor
  - `development-php-drupal/` - PHP/Drupal development profile
- `install/` - Modular installation scripts
  - `brew.sh` - Homebrew package manager installation
  - `ai/` - AI tools (Claude Code, ChatGPT, Cursor)
  - `desktop/` - Desktop environment (AeroSpace, SketchyBar, fonts)
  - `terminal/` - Terminal tools (Ghostty, tmux, CLI utils)
  - `editors/` - Text editors and IDEs
  - `development/` - Development tools (Languages, Docker)
  - `apps/` - GUI applications
  - `macos_settings.sh` - macOS system settings
  - `migrations.sh` - Migration system initialization
- `migrations/` - Database-style migrations for configuration updates
- `templates/makaron.conf.default` - Default user configuration template
- `bin/` - Executable scripts
  - `makaron-migrate` - Run pending migrations
  - `makaron-migration-status` - Show migration status
  - `makaron-dev-add-migration` - Create new migration (development)

## Migration System

Makaron includes a migration system similar to database migrations (like Rails or Drupal). This allows for safe, incremental updates to your configuration.

### How it works

- Migrations are timestamped shell scripts in the `migrations/` directory
- Each migration runs only once per installation
- State is tracked in `~/.local/state/makaron/migrations/`
- Migrations run automatically during `makaron-update`

### Creating Migrations

For development, use the helper script:

```bash
makaron-dev-add-migration
```

This creates a new migration file with the current timestamp and opens it in your editor.

### Migration Status

Check which migrations have been applied:

```bash
makaron-migration-status
```

### Manual Migration

Run pending migrations manually:

```bash
makaron-migrate
```

## User Configuration

Personal settings are stored in `~/.config/makaron/makaron.conf`. This file is created on install and preserved during updates.

Available settings:
```bash
BATTERY_LOW_THRESHOLD=20  # Battery warning threshold (%)
```

---

## Contributing

Contributions are welcome! If you'd like to contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please read [AGENTS.md](AGENTS.md) for development guidelines and code style.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## ⚠️ Experimental Project

**Please note:** Makaron is an experimental project under active development. Some features may not work perfectly yet, and you might encounter bugs or unexpected behavior. We welcome feedback and contributions to help improve the project!

If you encounter any issues, please:
- Check existing [GitHub Issues](https://github.com/grzegorzbartman/makaron/issues)
- Try running `makaron-reinstall` for a clean setup
- Report new issues with details about your system and the problem

Your patience and feedback are appreciated as we continue to improve Makaron! 🙏
