# Global agent rules

Shared across every laptop and every harness (Claude Code, Codex). Source of
truth is `~/agents/AGENTS.md`; `scripts/install` wires it into
`~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md`. Laptop-only rules go in
`~/agents/local/AGENTS.md`.

## Messages posted on my behalf

When you post on GitHub as me (PR/issue comments, review comments, PR
descriptions), end the text with this line, separated by a blank line:

— 👶 bébé, alex's agent · approved by alex

Only post after I've approved it. Don't add the footer to commit messages or code.

## Agent configuration

`~/.claude/settings.json`, `~/.claude/CLAUDE.md`, and `~/.codex/AGENTS.md` are
generated. Never edit them directly. Edit the source in `~/agents` and rerun
`~/agents/scripts/install`. Use the `agent-config` skill for any change to
settings, hooks, global rules, or skills.
