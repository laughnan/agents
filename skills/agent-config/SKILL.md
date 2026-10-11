---
name: agent-config
description: "Where agent configuration lives and how to change it. Use before editing Claude Code or Codex settings, hooks, permissions, env vars, global rules (CLAUDE.md / AGENTS.md), or personal skills, and when scripts/doctor reports drift. Edit sources in ~/agents, then regenerate."
license: MIT
metadata:
  source: original
---

# Agent config

Personal agent setup lives in the git repo `~/agents` and is synced across laptops.
Several files the harnesses read are **generated** from it. Editing a generated file
directly is wasted work: the next `scripts/install` overwrites it, and a hook blocks
the edit anyway.

## Where each change goes

| You want to change | Edit this | Not this (generated) |
|---|---|---|
| Claude Code setting, hook, permission, env var for every laptop | `~/agents/config/claude/settings.json` | `~/.claude/settings.json` |
| Same, but only this laptop | `~/agents/local/claude.settings.json` (gitignored) | `~/.claude/settings.json` |
| Global rules for every laptop | `~/agents/AGENTS.md` | `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md` |
| Global rules for this laptop | `~/agents/local/AGENTS.md` (gitignored) | same |
| A hook script | `~/agents/hooks/<name>.sh`, registered in one of the settings files above as `__AGENTS_HOME__/hooks/<name>.sh` | `~/.claude/hooks/` |
| A personal skill | `~/agents/skills/<name>/SKILL.md`, and add it to `skills/which/SKILL.md` | `~/.claude/skills/`, `~/.agents/skills/` (symlinks) |

Shared or local? Shared unless it depends on this machine: local paths, tools only
installed here, work vs personal identity, or a safety relaxation the user wants on
one laptop only. When unsure, ask.

To start a local file, copy its template: `cp ~/agents/local/claude.settings.json.example ~/agents/local/claude.settings.json`.

## Merge rules

`install` deep-merges shared then local into `~/.claude/settings.json`:
objects merge key by key, arrays concatenate without duplicates (so local hooks and
permissions add to shared ones), and for scalars local wins. A local file cannot
remove a shared array entry; change the shared file for that.

## After editing

```bash
~/agents/scripts/install --dry-run   # preview
~/agents/scripts/install             # apply (backs up anything it replaces)
~/agents/scripts/doctor              # confirm everything matches
```

New settings take effect in new sessions. If you changed a shared file or a skill,
tell the user to commit and push `~/agents` so other laptops get it with
`git pull && scripts/install`. Never commit `local/`.

## When doctor reports drift

Something wrote to a generated file directly (Claude Code's `/config`, another tool's
installer, a manual edit). Read the diff doctor prints, decide with the user whether
the change is wanted, fold wanted keys into the right source file from the table
above, then run `install`. Unwanted changes disappear on the next `install`.

## Built-in config tools

Claude Code's own config helpers (for example the `update-config` skill) write to
`~/.claude/settings.json`. Apply the same change to the source file here instead,
using that skill only as a reference for the settings schema.
