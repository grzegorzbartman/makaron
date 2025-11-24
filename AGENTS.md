# AGENTS.md

## General Guidelines
- Read `./docs/*` files for context.
- If a proposed change conflicts with documented behavior or guidelines, ask the user before proceeding. Update documentation only when explicitly requested.
- When user requests changes or improvements, ask 2-6 clarifying questions to precisely define the scope of work before implementing.
- If something doesn't work correctly after 2-3 iterations, search Google using MCP Playwright.

## Code Style & Principles
- Write short and concise shell scripts - only what's necessary, no unnecessary code or verbose comments.
- Keep code DRY (Don't Repeat Yourself) and follow SOLID principles.
- Commit changes frequently with concise single-line commit messages.

## Installation & Updates
- This is an open-source project on GitHub - changes must support both fresh installations (new users) and updates (existing users).
- Consider `install.sh` for new setups and migrations for existing installations.
- Each install script handles its own symlink management - detect and fix symlinks pointing to wrong locations automatically.
- Migrations can reference and source files from `install/` or other directories to avoid code duplication.

## Workflows
### Adding a New Theme
1. Create `themes/<name>` with `borders.colors`, `sketchybar.colors`, `mode` files and `backgrounds/` dir.
2. Create executable `bin/makaron-theme-<name>` script calling `makaron-switch-theme`.
3. Update `README.md` with the new theme name and command.

### Migration System
- Migrations are timestamped shell scripts in `migrations/`.
- Each migration runs only once per installation.
- State is tracked in `~/.local/state/makaron/migrations/`.
- Migrations run automatically during `makaron-update`.
- Use `makaron-dev-add-migration` to create new migrations.
- Use `makaron-migration-status` to check status.

## Troubleshooting & Known Issues
- **Migration Failures**: Ensure migration scripts are executable and handle errors gracefully. If a migration fails (e.g., "previous migration file didn't execute correctly"), check the script logic and manually verify the state.
- **Symlinks**: Install scripts should detect and fix symlinks pointing to wrong locations automatically.
- **Idempotency**: Scripts should be idempotent - running them multiple times should not cause issues.
