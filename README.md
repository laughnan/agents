# agents

My agent setup, synced across laptops: global rules, Claude Code settings and
hooks, reusable Claude Code agent roles, and a flat, hand-picked set of skills
that work in Claude Code and Codex.

Inspired by [pstack](https://github.com/cursor/plugins/tree/main/pstack),
[mattpocock/skills](https://github.com/mattpocock/skills), and
[steipete/agent-scripts](https://github.com/steipete/agent-scripts). See `NOTICE`.

## New laptop

```bash
git clone <this repo> ~/agents
~/agents/scripts/install --dry-run
~/agents/scripts/install
~/agents/scripts/doctor
```

Then add laptop-only overrides if needed (both gitignored):

```bash
cp ~/agents/local/claude.settings.json.example ~/agents/local/claude.settings.json
cp ~/agents/local/AGENTS.md.example ~/agents/local/AGENTS.md
~/agents/scripts/install
```

After any `git pull`, rerun `scripts/install`.

## What install does

| Source | Becomes |
|---|---|
| `agents/<name>.md` | symlinks in `~/.claude/agents/` (Claude Code only) |
| `skills/<name>/` | symlinks in `~/.claude/skills/` and `~/.agents/skills/` |
| `config/claude/settings.json` + `local/claude.settings.json` | generated `~/.claude/settings.json` |
| `AGENTS.md` + `local/AGENTS.md` | generated `~/.claude/CLAUDE.md` (imports), `~/.codex/AGENTS.md` |
| `.githooks/` | this repo's pre-commit (runs `validate-skills` and `validate-agents`) |

Generated files are never edited by hand: `hooks/guard-generated-config.sh` blocks
agents from doing it, and `scripts/doctor` reports drift. Anything install replaces
is backed up as `<file>.bak-agents-<timestamp>`. It never touches skill directories
it doesn't own (for example Reflect's app-managed skills). For agents, it also leaves
all real files and external links alone, even if their content matches. Stale links
into this checkout are pruned; a symlinked agent destination directory is left alone.

## Layout

```
AGENTS.md            global rules for every harness
config/claude/       shared Claude Code settings (__AGENTS_HOME__ = repo path)
local/               per-laptop overrides; only *.example is committed
hooks/               Claude Code hook scripts
agents/<name>.md     canonical Claude Code subagent definitions
docs/agents.md       role usage, permissions, and Codex compatibility
skills/<name>/       one flat directory per skill
scripts/             install, doctor, validators, test-agents, scratch-dir
scratch/             per-checkout agent working files (gitignored)
```

## Agent roles

- [`researcher`](agents/researcher.md): sourced answers, with observations and inferences separated
- [`reviewer`](agents/reviewer.md): independent requirements-and-diff review; no source edits

These are workers with separate context and explicit tool allowlists, not slash
commands or a new workflow engine. Claude discovers them after install. Codex does
not consume Claude frontmatter. See [usage and compatibility](docs/agents.md),
including manual Codex reuse, safe handoffs, and test commands.

## Skills

Not sure which to use? `/which`.

**User-invoked** (run only when typed)

- [`which`](skills/which/SKILL.md): router: which skill fits what you're doing
- [`pickup`](skills/pickup/SKILL.md) / [`handoff`](skills/handoff/SKILL.md): resume / pause a session via a handoff in `scratch/`
- [`ketchup`](skills/ketchup/SKILL.md): plain-words catch-up on this chat
- [`teach`](skills/teach/SKILL.md): plain explanation built on `how` + `why`
- [`bro`](skills/bro/SKILL.md): ELI5, restate the last message or a topic with no jargon
- [`blast-radius`](skills/blast-radius/SKILL.md): what a change could break, proven by running code
- [`grill`](skills/grill/SKILL.md): stress-test a plan until it's concrete
- [`to-spec`](skills/to-spec/SKILL.md) / [`to-tickets`](skills/to-tickets/SKILL.md): conversation to spec to tickets
- [`lean-pr-review`](skills/lean-pr-review/SKILL.md): concern-by-concern PR walkthrough, evidence-backed verdict, optional local HTML report
- [`autoreview`](skills/autoreview/SKILL.md): cross-provider review (Claude ⇄ Codex)
- [`land-pr`](skills/land-pr/SKILL.md): rebase, gate, merge, verify MERGED
- [`retro`](skills/retro/SKILL.md): improve the agent setup after a session
- [`capture-learnings`](skills/capture-learnings/SKILL.md): turn feedback into durable rules

**Model-invoked** (the agent reaches for these itself)

- [`how`](skills/how/SKILL.md) / [`why`](skills/why/SKILL.md): how code works / why it's shaped this way
- [`diagnose`](skills/diagnose/SKILL.md): disciplined bug and perf diagnosis loop
- [`tdd`](skills/tdd/SKILL.md): red-green vertical slices
- [`agent-config`](skills/agent-config/SKILL.md): where config lives and how to change it
- [`principle-fix-root-causes`](skills/principle-fix-root-causes/SKILL.md),
  [`principle-prove-it-works`](skills/principle-prove-it-works/SKILL.md),
  [`principle-subtract-before-you-add`](skills/principle-subtract-before-you-add/SKILL.md)

## Adding a skill

1. Create `skills/<name>/SKILL.md` with `name`, a double-quoted `description`, and
   `disable-model-invocation: true` if it should only run when typed.
2. Add it to the map in `skills/which/SKILL.md` and to the list above.
3. `scripts/install` (validates, then links it).
