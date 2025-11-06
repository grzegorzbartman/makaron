# Migration Best Practices

This document defines the standard structure and best practices for creating migrations in Makaron, based on analysis of all existing migrations.

## Standard Migration Structure

Every migration MUST follow this exact structure:

```bash
#!/bin/bash

# Migration: Brief title
# Detailed description of what this migration does and why

set -e

error_exit() {
  echo -e "\033[31mERROR: Migration failed! Manual intervention required.\033[0m" >&2
  exit 1
}

trap error_exit ERR

echo "Running migration: Brief title"

# Set MAKARON_PATH if not already set
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

# Migration logic here
# ...

echo "Migration completed successfully"
```

## Required Components

### 1. Shebang and Header
- **Always** start with `#!/bin/bash`
- **Always** include a comment with format: `# Migration: Title`
- **Always** include a second comment line with detailed description

### 2. Error Handling
- **Always** use `set -e` to exit on any error
- **Always** define `error_exit()` function with red error message
- **Always** use `trap error_exit ERR` to catch errors

### 3. MAKARON_PATH
- **Always** set `MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"`
- This ensures the migration works whether MAKARON_PATH is already set or not

### 4. Messages
- **Always** start with: `echo "Running migration: Title"`
- **Always** end with: `echo "Migration completed successfully"`
- Use descriptive messages for each step

## Migration Types and Patterns

### Type 1: Installing New Tools/Applications

**Pattern**: Source installation scripts from `install/` directory

```bash
#!/bin/bash

# Migration: Install ToolName
# Adds installation script for ToolName tool for existing users

set -e

error_exit() {
  echo -e "\033[31mERROR: Migration failed! Manual intervention required.\033[0m" >&2
  exit 1
}

trap error_exit ERR

echo "Running migration: Install ToolName"

MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

# Install ToolName
if [ -f "$MAKARON_PATH/install/tools/toolname.sh" ]; then
    echo "Installing ToolName..."
    source "$MAKARON_PATH/install/tools/toolname.sh"
else
    echo "ToolName installation script not found, skipping"
fi

# Individual installation scripts check if applications are already installed (idempotent)
echo "Migration completed successfully"
```

**Key points**:
- Check if installation script exists before sourcing
- Use appropriate directory: `tools/`, `development/`, or `ui/`
- Installation scripts are idempotent (check if already installed)

### Type 2: Installing Multiple Tools

**Pattern**: Group related tools, separate by category

```bash
#!/bin/bash

# Migration: Install new tools and applications
# Adds installation scripts for tool1, tool2, tool3 for existing users

set -e

error_exit() {
  echo -e "\033[31mERROR: Migration failed! Manual intervention required.\033[0m" >&2
  exit 1
}

trap error_exit ERR

echo "Running migration: Install new tools and applications"

MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

# Install tools
if [ -f "$MAKARON_PATH/install/tools/tool1.sh" ]; then
    echo "Installing Tool1..."
    source "$MAKARON_PATH/install/tools/tool1.sh"
else
    echo "Tool1 installation script not found, skipping"
fi

if [ -f "$MAKARON_PATH/install/tools/tool2.sh" ]; then
    echo "Installing Tool2..."
    source "$MAKARON_PATH/install/tools/tool2.sh"
else
    echo "Tool2 installation script not found, skipping"
fi

# Install UI applications
if [ -f "$MAKARON_PATH/install/ui/app1.sh" ]; then
    echo "Installing App1..."
    source "$MAKARON_PATH/install/ui/app1.sh"
else
    echo "App1 installation script not found, skipping"
fi

# Individual installation scripts check if applications are already installed (idempotent)
echo "Migration completed successfully"
```

**Key points**:
- Group tools by category (tools, development, ui)
- Use comments to separate sections: `# Install tools`, `# Install UI applications`
- Each tool gets its own if-block with error handling

### Type 3: Idempotent Checks at Start

**Pattern**: Check if migration already applied, exit early if so

```bash
#!/bin/bash

# Migration: Setup something
# Description of what this migration does

set -e

error_exit() {
  echo -e "\033[31mERROR: Migration failed! Manual intervention required.\033[0m" >&2
  exit 1
}

trap error_exit ERR

echo "Running migration: Setup something"

MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

# Check if migration is already applied (idempotent)
if [ condition_already_met ]; then
    echo "Migration already applied, skipping"
    exit 0
fi

# Perform migration steps
# ...

echo "Migration completed successfully"
```

**Key points**:
- Check condition at the start
- Exit with code 0 if already applied (not an error)
- Use clear condition checks

### Type 4: System Configuration Changes

**Pattern**: Modify system settings, check before applying

```bash
#!/bin/bash

# Migration: Configure system setting
# Applies system configuration for better integration

set -e

error_exit() {
  echo -e "\033[31mERROR: Migration failed! Manual intervention required.\033[0m" >&2
  exit 1
}

trap error_exit ERR

echo "Running migration: Configure system setting"

# Check if setting is already applied (idempotent)
SETTING_VALUE=$(defaults read domain.key 2>/dev/null || echo "0")

if [ "$SETTING_VALUE" = "expected_value" ]; then
    echo "Setting already applied, skipping"
    exit 0
fi

# Apply setting
if [ "$SETTING_VALUE" != "expected_value" ]; then
    echo "Applying setting..."
    if defaults write domain.key -bool true 2>/dev/null; then
        echo "✓ Setting applied"
    else
        echo "⚠️  Could not apply setting automatically."
        echo "   Please apply manually: Instructions here"
    fi
fi

# Restart services if needed
echo "Applying changes..."
killall ServiceName 2>/dev/null || true

echo "Migration completed successfully"
```

**Key points**:
- Use `defaults read` with fallback for idempotent checks
- Handle errors gracefully with warnings
- Restart services if needed (with `|| true` to avoid errors)

### Type 5: File System Operations

**Pattern**: Create directories, symlinks, move files

```bash
#!/bin/bash

# Migration: Setup directory structure
# Creates necessary directories and symlinks

set -e

error_exit() {
  echo -e "\033[31mERROR: Migration failed! Manual intervention required.\033[0m" >&2
  exit 1
}

trap error_exit ERR

echo "Running migration: Setup directory structure"

MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

# Ensure directory exists
mkdir -p "$MAKARON_PATH/some/directory"

# Check if symlink already exists
if [ -L "$MAKARON_PATH/target" ]; then
    echo "Symlink already exists, skipping"
    exit 0
fi

# Create symlink
if [ -d "$MAKARON_PATH/source" ]; then
    ln -s "$MAKARON_PATH/source" "$MAKARON_PATH/target"
    echo "Symlink created successfully"
else
    echo "Warning: Source directory not found. Will be set up on next update."
    exit 0
fi

echo "Migration completed successfully"
```

**Key points**:
- Use `mkdir -p` for directories (idempotent)
- Check if symlinks/files exist before creating
- Handle missing dependencies gracefully

## Directory Organization

When installing tools, use the correct directory:

- **`install/tools/`** - System utilities, command-line tools (htop, jq, gh, ffmpeg, etc.)
- **`install/development/`** - Development tools (node, rbenv, vscode, cursor, etc.)
- **`install/ui/`** - GUI applications (discord, spotify, steam, etc.)

## Common Patterns

### Pattern: Check File Exists Before Sourcing

```bash
if [ -f "$MAKARON_PATH/install/path/to/script.sh" ]; then
    echo "Installing..."
    source "$MAKARON_PATH/install/path/to/script.sh"
else
    echo "Installation script not found, skipping"
fi
```

### Pattern: Idempotent Check with Early Exit

```bash
if [ condition ]; then
    echo "Already applied, skipping"
    exit 0
fi
```

### Pattern: Graceful Error Handling

```bash
if command; then
    echo "✓ Success"
else
    echo "⚠️  Warning: Could not complete automatically"
    echo "   Manual instructions here"
fi
```

### Pattern: Service Restart

```bash
killall ServiceName 2>/dev/null || true
```

## Naming Conventions

### File Names
- Use Unix timestamp: `{timestamp}.sh`
- Generate with: `date +%s`
- Example: `1762460788.sh`

### Comments
- First line: `# Migration: Brief Title`
- Second line: `# Detailed description explaining what and why`

### Echo Messages
- Start: `echo "Running migration: Brief Title"`
- Steps: `echo "Installing ToolName..."` or `echo "Applying setting..."`
- End: `echo "Migration completed successfully"`

## Do's and Don'ts

### ✅ DO

- Always use the standard structure
- Always include error handling (`set -e`, `error_exit`, `trap`)
- Always set `MAKARON_PATH`
- Always check if files exist before sourcing
- Always make migrations idempotent
- Always use descriptive messages
- Always end with success message
- Group related installations together
- Use appropriate directory (tools/development/ui)
- Handle missing dependencies gracefully

### ❌ DON'T

- Don't skip error handling
- Don't assume MAKARON_PATH is set
- Don't source files without checking if they exist
- Don't make migrations that can't be run multiple times
- Don't use different message formats
- Don't mix installation types without grouping
- Don't fail hard on missing optional dependencies
- Don't forget to make file executable: `chmod +x migrations/TIMESTAMP.sh`

## Examples from Codebase

### Good Example: Single Tool Installation
See: `migrations/1762460788.sh` (Flameshot)

### Good Example: Multiple Tools
See: `migrations/1762457117.sh` (Multiple tools and applications)

### Good Example: System Configuration
See: `migrations/1761365899.sh` (Dock/Menu Bar settings)

### Good Example: File System Operations
See: `migrations/1761364893.sh` (Theme system initialization)

## Testing Migrations

Before committing a migration:

1. **Syntax check**: `bash -n migrations/TIMESTAMP.sh`
2. **Test locally**: Run the migration manually
3. **Verify idempotency**: Run it twice, should skip on second run
4. **Check error handling**: Test with missing dependencies

## Quick Reference Template

Copy this template for new migrations:

```bash
#!/bin/bash

# Migration: [Title]
# [Description]

set -e

error_exit() {
  echo -e "\033[31mERROR: Migration failed! Manual intervention required.\033[0m" >&2
  exit 1
}

trap error_exit ERR

echo "Running migration: [Title]"

MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

# [Migration logic here]

echo "Migration completed successfully"
```

