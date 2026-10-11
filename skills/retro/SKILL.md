---
name: retro
description: "Retrospective on a coding session that proposes improvements to the agent environment (navigation pointers, automated checks, review rules, AGENTS.md trimming, skills, tool economy) in the current repo and ~/agents. Use when the user says \"retro\", \"retrospective\", or \"what should we change after this session\"."
disable-model-invocation: true
license: MIT
metadata:
  source: https://github.com/mattpocock/skills/tree/main/skills/engineering/retro
---

# Retro

You are suggesting improvements to the coding agent's **environment** so future runs go better. The environment is:

- **The current repo**: its `AGENTS.md` / `CLAUDE.md`, rules files, docs, lint/typecheck/test config, hooks, CI.
- **`~/agents`**: the user's personal skills and global `AGENTS.md`, loaded into every session.

## Steps

1. **Read the primary sources** for the session the user names; default to the current one. For past sessions, search local transcripts (e.g. `~/.claude/projects/` for Claude Code, `~/.codex/sessions/` for Codex). Note where time, tokens, or mistakes went.

2. **Find candidates** in these categories:

- **Navigation**: did the agent struggle to find the right files? Hidden dependencies between files? Would a **navigation pointer** help? _Use when_ finding information took a long time.
- **Automated checks**: could a lint, type, test, or filesystem check have caught a mistake? Read the repo's existing check commands first (package scripts, Makefile, CI workflow): a check that exists but is unwired or silently broken is the finding, not a reinvention. A repo with no **guardrail** (no pre-commit hook and no CI job running lint/typecheck/test) is itself a finding. _Use when_ the agent made a mistake a check could catch, or there is no guardrail.
- **Coding standards**: should review enforce a new rule, or drop/clarify one? Classify first. A **mechanical** violation (fixed syntactic pattern, banned API, import shape, file location) gets a deterministic check: a custom lint rule, pre-commit hook, or CI job, whichever is cheapest given the repo's language and existing guardrails. Default to building the check over writing the rule. Reserve written standards for genuine **judgement calls** (cross-file consistency, matching surrounding style). _Use when_ review failed to catch a mistake.
- **AGENTS.md size**: should steering instructions move into review standards, a skill, or an automated check? _Use when_ the repo or `~/agents` AGENTS.md is large.
- **Skills**: did a skill in `~/agents` misfire, fail to trigger, or give stale guidance? Is there a repeated workflow that should become a skill? _Use when_ the session repeated a multi-step procedure or a skill got in the way.
- **Tool economy**: expensive or token-inefficient tool calls, CLIs, or MCP servers that could be streamlined. _Use when_ the agent made an expensive call.
- **No-ops**: instructions in steering files that don't change behavior. _Use when_ steering files are large and unwieldy.
- **Information access**: could the agent get crucial information it lacked? Teeing dev server logs to a file, read-only access to third-party services. _Use when_ something crucial was unavailable.

3. **Present candidates in order of severity.** For each: what happened (with evidence from the session), the proposed change, and exactly where it goes (repo vs `~/agents`, which file). Don't apply changes until the user picks which to do.

4. **Mark the session done** once the picked changes are applied (or the user picks none). Prefix the current session's title with `✅ ` unless it already has one. In the Claude desktop app, load `mcp__ccd_session_mgmt__get_session` and `mcp__ccd_session_mgmt__set_session_title` via ToolSearch, read the title with `get_session("self")`, then call `set_session_title("self", "✅ <title>")`. Without those tools (terminal CLI, Codex), tell the user to rename it to `✅ <title>` themselves.

## Reference

### Implementation vs review

Implementation carries the most **context pressure**: exploration, writing code, debugging. Review receives a diff, needs no exploration, and rarely writes code. So coding standards belong to review, not to the implementation agent's always-loaded context.

### Where things go

- `AGENTS.md` / `CLAUDE.md` (repo or `~/agents`): pushed into every session's context. Use very sparingly, mostly for navigation pointers.
- Review standards (e.g. a `CODING_STANDARDS.md` or the repo's equivalent): read during review, not implementation. Split into pointed-to docs if it passes ~1,000 lines.
- Docs: reference files pointed to from elsewhere. Look for existing docs before writing new ones.
- Skills (in `~/agents/skills/` or the repo's skills dir): only the description is always in context, so they suit on-demand docs and user-invoked commands.

### Writing for agents

Proposed text should be terse and operational: imperative, specific, one idea per line, no rationale the agent doesn't need to act. Prefer a pointer to an existing doc over restating it.
