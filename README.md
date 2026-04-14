# Makaron — macOS Productivity Environment

> **Why "Makaron"?** The name comes from the Polish word for "pasta" 🍝, which sounds similar to "Mac" — a playful nod to macOS while keeping a Polish identity.

A high-performance macOS desktop setup for technical founders and developers who juggle code, teams, and AI tools all day long. Tiling windows, keyboard-driven navigation, time tracking, task overview, and seven AI assistants — installed with a single command.

## Who is this for?

Makaron was built for people who context-switch constantly between writing code, reviewing PRs, prompting AI, drafting sales emails, checking Todoist, and jumping on calls — often within the same hour.

- **Technical CEOs & CTOs** who still code but also run sales, marketing, and hiring
- **Startup founders** managing product, engineering, and business simultaneously
- **Senior developers & tech leads** coordinating across multiple projects and teams
- **AI-heavy workflows** — if you regularly use Claude, ChatGPT, Cursor, and Codex side by side
- **Anyone who has 15+ windows open** and needs them organized, not stacked
- **Single-monitor users** — Makaron is designed for working on one screen. Multi-monitor setups are supported, but a single display with workspaces is faster to navigate and keeps you more focused than spreading windows across monitors.

### The problem it solves

macOS has built-in workspaces and window tiling, but both are too slow for real work. Switching spaces plays a scroll animation you can't skip, and tiling is limited to two windows with manual drag-and-drop. If you context-switch 50 times a day, those animations and mouse gestures add up fast. AeroSpace replaces both with instant keyboard-driven workspaces and automatic tiling — no animations, no dragging, no wasted seconds. Makaron gives you:

- **Tiling window management** — every window has its place, every workspace has a purpose
- **Keyboard-first navigation** — switch workspaces, move windows, launch apps without touching the mouse
- **At-a-glance status bar** — timer, tasks, calendar, system stats — all in the native macOS menu bar
- **AI tools ready to go** — Claude, ChatGPT, Cursor, Codex, Gemini CLI, OpenCode, Claude Code
- **Time tracking built in** — tag your work (sales, engineering, meetings) and see where your day went

## Requirements

- macOS (tested on macOS 26 Tahoe)
- Git

## Quick Installation

```bash
curl -sL https://raw.githubusercontent.com/grzegorzbartman/makaron/main/install.sh | bash
```

This will:
- Clone the repository to `~/.local/share/makaron`
- Install Homebrew (if not present)
- Set up the desktop environment (AeroSpace, MakaronBar, Ghostty)
- Let you pick optional packages (AI tools, dev tools, editors, apps)
- Configure macOS settings for a keyboard-driven workflow

## What Gets Installed

### Core (always installed)

| Component | What it does |
|---|---|
| **AeroSpace** | Tiling window manager — automatic layouts, workspaces, keyboard control |
| **MakaronBar** | Native menu bar app — workspaces, timer, Todoist, calendar, system stats |
| **Ghostty** | Fast GPU-accelerated terminal emulator |
| **Nerd Fonts** | Developer fonts with icon support |
| **Timewarrior** | Time tracking backend for the MakaronBar timer |

### Optional packages (you choose during install)

**AI Tools:**
Claude, Claude Code, ChatGPT, Cursor, Codex, OpenCode, Gemini CLI

**Development:**
Docker, DDEV, Composer, Node.js, Yarn, pnpm, fnm, rbenv, pipx, gh, LazyDocker, LazyGit, Bruno, Sequel Ace, Upsun CLI

**Editors:**
VSCode, Cursor, Sublime Text, Neovim + LazyVim

**Terminal tools:**
btop, htop, tmux, fzf, ncdu, tree, ffmpeg, Fresh Editor, Powerlevel10k

**Desktop extras:**
Command X, Stats

**Apps:**
Todoist, Slack, Spotify, Flameshot, VLC

Run `makaron-select-packages` anytime to change your selection.

## How it works

### Workspaces

AeroSpace gives you 12 workspaces (`1`–`0`, `Q`, `W`). Each one is a separate context:

- Workspace **1** — Cursor + terminal (coding)
- Workspace **2** — Browser (research, PRs)
- Workspace **3** — Slack + Mimestream (communication)
- Workspace **4** — Todoist + Notes (planning)
- ...you define your own layout

Switch instantly with `Alt+1` through `Alt+0`. Move windows with `Alt+Shift+1` through `Alt+Shift+0`. No mouse needed.

### MakaronBar

A native macOS menu bar app (built in Swift/AppKit) that shows:

- **Workspace indicators** — see which workspaces have windows, click to switch
- **Timer** — start/stop time tracking with tags (sales, engineering, meetings, etc.)
- **Todoist** — your top tasks at a glance
- **Calendar** — next event
- **System stats** — CPU, memory, battery, storage, WiFi

Press `Alt+M` to open the full dashboard panel. Configure what shows in the bar vs. the panel via Options.

### Time tracking

MakaronBar integrates with Timewarrior for local, private time tracking:

```bash
makaron-timer start sales       # Start tracking "sales"
makaron-timer stop              # Stop
makaron-timer toggle meeting    # Toggle tracking
makaron-timer recent            # Recent entries
makaron-timer today             # Today's summary
```

Or use the dashboard panel (`Alt+M`) to start/stop timers with one click. Tags are configurable in `~/.config/makaron/makaron.conf`.

## Commands

| Command | What it does |
|---|---|
| `makaron-reload` | Restart MakaronBar + reload AeroSpace config |
| `makaron-update` | Pull latest version, run migrations, reload |
| `makaron-reinstall` | Full clean reinstall |
| `makaron-timer` | Time tracking (start, stop, toggle, status, recent, today) |
| `makaron-debug` | Diagnose system status |
| `makaron-select-packages` | Re-run package selection |
| `makaron-macos-config-reload` | Re-apply macOS settings |

> **Tip:** If MakaronBar is not running, use `makaron-reload` to start it.

## Keyboard Shortcuts

### Window management
| Shortcut | Action |
|---|---|
| `Ctrl+Alt+Arrow` | Focus window in direction |
| `Alt+Shift+Arrow` | Move window in direction |
| `Alt+Minus / Equal` | Resize window |
| `Alt+Slash` | Toggle tiles layout |
| `Alt+F` | Toggle floating/tiling |

### Workspaces
| Shortcut | Action |
|---|---|
| `Alt+1`–`0` | Switch to workspace 1–10 |
| `Alt+Q / W` | Switch to workspace Q / W |
| `Alt+Shift+1`–`0` | Move window to workspace |
| `Alt+Left / Right` | Previous / next workspace |
| `Cmd+Alt+Left / Right` | Move window to prev / next workspace |

### Multi-monitor
| Shortcut | Action |
|---|---|
| `Ctrl+Tab` | Focus next monitor |
| `Ctrl+Alt+Shift+Arrow` | Move window to other monitor |

### Quick launch
| Shortcut | App |
|---|---|
| `Ctrl+Alt+B` | Safari |
| `Ctrl+Alt+C` | Cursor |
| `Ctrl+Alt+T` | Ghostty |
| `Ctrl+Alt+P` | PhpStorm |
| `Ctrl+Alt+Z` | Todoist |
| `Ctrl+Alt+N` | Notes (new note) |
| `Ctrl+Alt+M` | Mimestream |

### MakaronBar
| Shortcut | Action |
|---|---|
| `Alt+M` | Open dashboard panel (configurable in Options) |

## Configuration

Personal settings in `~/.config/makaron/makaron.conf`:

```bash
BATTERY_LOW_THRESHOLD=20                    # Battery warning %
MAKARON_TIMER_TAGS="sales,marketing,other"  # Timer tags
MAKARON_TIMER_DEFAULT_TAG=other             # Default timer tag
MAKARON_TIMER_RECENT_COUNT=4                # Recent entries shown
MAKARON_NOTES_ENABLED=false                 # Apple Notes quick action
```

MakaronBar items (battery, CPU, timer, Todoist, calendar, etc.) can be set to **Top Bar**, **Menu**, or **Off** via the Options panel.

### Todoist integration

MakaronBar shows your top tasks from Todoist's "Today" view. It uses the official [Todoist CLI](https://github.com/Doist/todoist-cli) (`td`), which is installed automatically during setup.

After install, authenticate once:

```bash
td auth login
```

Once authenticated, MakaronBar picks up your tasks automatically. The Todoist desktop app is available as an optional package during install.

## Troubleshooting

| Problem | Solution |
|---|---|
| `makaron-*` commands not found | `source ~/.zshrc` or restart terminal |
| MakaronBar not showing | `makaron-reload` |
| AeroSpace not tiling | `makaron-reload` or `open -a AeroSpace` |
| Update fails (ghostty config) | `cd ~/.local/share/makaron && git update-index --no-skip-worktree configs/ghostty/config && git add configs/ghostty/config && makaron-update -y` |
| Something else | `makaron-debug` for full diagnostics |

Full reinstall: `makaron-reinstall`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Open a Pull Request

See [AGENTS.md](AGENTS.md) for development guidelines.

## License

MIT License — see [LICENSE](LICENSE).

---

**Makaron is an experimental project under active development.** Some features may not work perfectly yet. If you encounter issues, check [GitHub Issues](https://github.com/grzegorzbartman/makaron/issues), try `makaron-reinstall`, or report a new issue.
