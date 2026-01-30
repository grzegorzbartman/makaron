---
name: pre-commit-review
description: Pre commit review
disable-model-invocation: true
---

# Pre commit review


- read AGENTS.md
- run: git status
- run: git diff
- check if therer are any risk that code will break something - for new users and existing users (update command and ./migrations/ folder)
- check if new keyboard shortcuts don't conflict with Polish characters (lowercase and uppercase: ą, ć, ę, ł, ń, ó, ś, ź, ż, Ą, Ć, Ę, Ł, Ń, Ó, Ś, Ź, Ż)
