# Editor Profiles

Editor profiles for VSCode and Cursor. Each profile contains settings, extensions, and keybindings.

## Usage

```bash
# Apply to both Cursor and VSCode
makaron-apply-editor-profile development-php-drupal

# Apply to Cursor only
makaron-apply-editor-profile development-php-drupal --cursor-only

# Apply to VSCode only
makaron-apply-editor-profile development-php-drupal --vscode-only
```

## Available Profiles

### `development-php-drupal`

PHP/Drupal development profile with:
- **Theme**: Auto dark/light (JetBrains Darcula / Default Light+)
- **Font**: MesloLGS NF
- **Extensions**: PHP Intelephense, Xdebug, DDEV Manager, Twig, Drupal Snippets, ESLint, etc.
- **Drupal file associations**: `.module`, `.inc`, `.install`, `.theme`, `.profile`, `.tpl.php`

## Profile Structure

```
profiles/
  <profile-name>/
    settings.json       # Editor settings
    extensions.txt      # Extension IDs (one per line, # for comments)
    keybindings.json    # Custom keybindings
```

## Creating New Profiles

1. Create a directory under `profiles/`
2. Add `settings.json` with your settings
3. Add `extensions.txt` with extension IDs
4. Optionally add `keybindings.json`
