---
name: handoff
description: "Package session state (status, git tree, branch/PR/CI, running processes, checks, next steps, gotchas) into a standalone handoff, written to .agents/handoff.md and printed, so a fresh session can resume via pickup. Use when the user says \"handoff\", \"write a handoff\", or is ending a session."
disable-model-invocation: true
license: MIT
metadata:
  source: "https://github.com/steipete/agent-scripts/blob/main/docs/slash-commands/handoff.md, https://github.com/openclaw/agent-skills/tree/main/skills/handoff"
---

# Handoff

Package the current state so the next agent (or future you) can resume fast. The `pickup` skill reads what this writes.

## Location

`<repo root>/.agents/handoff.md` (`git rev-parse --show-toplevel`; outside a repo, the current directory). Overwrite any previous handoff; it is a snapshot, not a log.

Keep it out of commits without touching tracked files: if `git check-ignore -q .agents/handoff.md` fails, append `.agents/handoff.md` to `.git/info/exclude` (local only).

## Gather

Collect facts; don't guess. Mark anything unverified as such.

- `git status -sb`, `git log --oneline @{u}..` (unpushed commits; note if no upstream), `git stash list`.
- Branch and PR: `gh pr view --json number,url,state,isDraft` for the current branch, and `gh pr checks` for CI if a PR exists.
- Running processes you started: dev servers, watchers, debuggers, background jobs. How to reach each (port, URL, log file, terminal or tmux session name).
- Which checks/tests ran this session and their results.

## Write

Concise bullets, in this order:

```markdown
# Handoff: <short task title>
_Written <date/time>, branch `<branch>`_

## Status
- Goal: <what we were doing and why>
- Done: <...>
- Pending: <...>
- Blockers / open questions: <...>

## Working tree
- <git status summary; unpushed commits; stashes>

## Branch / PR / CI
- <branch, PR number + URL, CI status, or "no PR">

## Running processes
- <what, where, how to attach or read its output; or "none">

## Checks
- Ran: <command> -> <result>
- Still to run: <...>

## Next steps
1. <first thing the next agent should do>
2. ...

## Risks / gotchas
- <flaky tests, feature flags, brittle areas, env vars or credentials needed (names only, never values)>

## For the next agent
- Re-check live git / PR / CI state before acting; this file may be stale.
- Review the relevant code and decide whether the plan still holds before changing anything.
- Do not push, merge, close issues/PRs, or post public comments unless the user asks.
```

Rules:

- Enough context for a fresh agent to orient; no brain dump.
- Repo-relative paths, symbols, commands, PR/issue URLs and exact error text. No absolute or home-directory paths.
- No secrets. Name env vars, never their values.
- No invented facts.

## Finish

Write the file, print the full handoff in your reply, and state the path. Optionally copy it to the clipboard (`pbcopy`, `wl-copy`, `xclip`, or `clip.exe`), piping from the file rather than quoting inline.
