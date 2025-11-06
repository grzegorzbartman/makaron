# Migration System

## Overview

Makaron uses a database-style migration system (similar to Rails or Drupal) to manage configuration updates safely and incrementally. This allows for controlled, versioned changes to user configurations without breaking existing installations.

## How It Works

> **Note**: For complete directory structure, see [directory-structure.md](./directory-structure.md)

### State Tracking

Migration state is stored in: `~/.local/state/makaron/migrations/`

```
~/.local/state/makaron/migrations/
├── 1734567890.sh          # Empty file = migration completed
├── 1761363175.sh          # Empty file = migration completed
└── skipped/
    └── 1234567890.sh      # Empty file = migration skipped by user
```

## Installation Flow

When a user runs `install.sh` for the first time:

1. **Repository is cloned** to `~/.local/share/makaron`
2. **install/migrations.sh runs** and marks all existing migrations as "completed"
   - This prevents running migrations that were already applied during initial setup
   - Creates state directory: `~/.local/state/makaron/migrations/`
   - Creates empty marker files for each migration in `migrations/` directory

## Update Flow

When a user runs `makaron-update`:

1. **Fetches latest changes** from git repository
   ```bash
   git fetch origin main
   git reset --hard origin/main
   ```
2. **New migration files** are pulled into `~/.local/share/makaron/migrations/`
3. **makaron-migrate runs automatically** and:
   - Scans `~/.local/share/makaron/migrations/*.sh`
   - Identifies migrations without marker files in state directory
   - Runs pending migrations in chronological order (sorted by timestamp)
   - Creates marker files for completed migrations
4. **Configurations are reloaded** via `makaron-reload-aerospace-sketchybar`

## Creating Migrations

> **📖 For detailed best practices and templates, see [migration-best-practices.md](./migration-best-practices.md)**

### File Naming Convention

Migrations use Unix timestamp format: `{timestamp}.sh`

Example: `1761363175.sh` (created on 2025-10-25)

Generate timestamp: `date +%s`

### Quick Reference

1. **Idempotent** - Migrations should be safe to run multiple times
2. **Error handling** - Use `set -e` and trap errors
3. **Exit 0 if already applied** - Check if work is already done
4. **Clear messages** - Explain what's happening
5. **Executable** - Set permissions: `chmod +x migrations/TIMESTAMP.sh`

See [migration-best-practices.md](./migration-best-practices.md) for complete templates and patterns.

### Development Helper

Use the helper script to create new migrations:

```bash
makaron-dev-add-migration
```

This creates a timestamped file and opens it in your editor.

## User Commands

### Check Migration Status

```bash
makaron-migration-status
```

Shows:
- Completed migrations (✓)
- Pending migrations (○)
- Skipped migrations (⊗)

### Run Pending Migrations Manually

```bash
makaron-migrate
```

Runs all pending migrations. Useful for testing or if update failed.

### Failed Migrations

If a migration fails, the user is prompted:
```
Migration 1234567890 failed. Skip and continue? (y/N)
```

- **Yes** - Creates marker in `skipped/` directory, continues with other migrations
- **No** - Stops execution, requires manual intervention

## AI/LLM Integration Notes

### When to Create Migrations

Create a new migration when:
- Fixing bugs in existing installations (like PATH issues)
- Moving/renaming configuration files
- Updating symlinks
- Adding new required configurations
- Breaking changes that need gradual rollout

### When NOT to Create Migrations

Don't create migrations for:
- New features that don't affect existing installations
- Changes only in `install.sh` (new installs only)
- Documentation updates
- New plugins or optional features

### Example Scenarios

#### Scenario 1: Fixed Bug in install.sh

```
Problem: PATH not added correctly to .zshrc
Solution:
  1. Fix install.sh for new installations
  2. Create migration to fix existing installations
```

File: `migrations/1761363175.sh`
```bash
#!/bin/bash
# Migration: Fix PATH configuration in shell config files
# Re-adds PATH using more robust method
# ...
```

#### Scenario 2: Moving Configuration Files

```
Problem: Config files moved from root to configs/ directory
Solution: Create migration to move files in existing installations
```

File: `migrations/1734567890.sh`
```bash
#!/bin/bash
# Migration: Move configurations to configs/ directory
# Moves aerospace.toml, sketchybar/, etc. to new location
# ...
```

## Technical Details

### Migration Execution

`bin/makaron-migrate` implementation:
- Uses bash glob to iterate: `~/.local/share/makaron/migrations/*.sh`
- Sorts files naturally (timestamp order)
- Checks state directory before running each migration
- Creates marker file only on successful completion (exit 0)
- Handles user interaction for failed migrations

### State Management

- **Completed**: Empty file in `~/.local/state/makaron/migrations/`
- **Skipped**: Empty file in `~/.local/state/makaron/migrations/skipped/`
- **Pending**: No file in either location

### Integration Points

1. `install.sh` → `install/all.sh` → `install/migrations.sh`
2. `makaron-update` → `makaron-migrate`
3. `makaron-reinstall` → `install/all.sh` → `install/migrations.sh`

## Troubleshooting

### Migration Not Running

Check if already marked as completed:
```bash
ls ~/.local/state/makaron/migrations/
```

Remove marker to re-run:
```bash
rm ~/.local/state/makaron/migrations/TIMESTAMP.sh
makaron-migrate
```

### Migration Fails Repeatedly

Check migration logs and fix manually, then:
```bash
touch ~/.local/state/makaron/migrations/TIMESTAMP.sh
```

### All Migrations Marked as Completed

This is normal for fresh installations - `install/migrations.sh` marks all existing migrations as completed to prevent running setup steps that were already performed during installation.

