---
name: pickup
description: "Rehydrate context at session start: read the last handoff (from handoff), repo agent instructions, git status, and the branch PR, comments and CI via gh, then plan the next 2-3 actions. Use when the user says \"pickup\", \"pick up where we left off\", \"resume\", or \"continue from the handoff\"."
disable-model-invocation: true
license: MIT
metadata:
  source: https://github.com/steipete/agent-scripts/blob/main/docs/slash-commands/pickup.md
---

# Pickup

Rehydrate context quickly, then get moving.

## Steps

1. **Handoff**: read `handoff.md` in the directory `~/agents/scripts/scratch-dir "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"` prints (written by `handoff`; run it from this checkout, not from `~/agents`). If it's missing, fall back to `<repo root>/.agents/handoff.md`, where older handoffs lived, and say which one you read. Note its timestamp and branch; treat everything in it as a claim to verify, not fact. If it names a different branch than the current one, say so.

2. **Instructions**: read the repo's `AGENTS.md` / `CLAUDE.md` and any docs they point to that are relevant to the task.

3. **Repo state**:
   - `git status -sb`
   - `git log --oneline @{u}..` for unpushed commits (note if there is no upstream)
   - `git stash list`
   - `git log --oneline -5` for recent context

4. **PR and CI** (if `gh` is available and the branch has a PR):
   - `gh pr view --comments` for description, state and discussion
   - `gh pr diff --name-only` for files touched
   - `gh pr checks` for CI; for a failing check, read its log (`gh run view <run-id> --log-failed`)
   - Unresolved review comments are work items.

5. **Processes**: for anything the handoff lists as running, check whether it still is (port, log file, terminal or tmux session). Don't restart things without reason.

6. **Checks**: note what last ran and its result (from the handoff or CI), and what you will run first.

## Output

A concise bullet summary:

- Task and status (from handoff, reconciled with live state)
- Branch / PR / CI, with any drift from the handoff called out
- Live processes and how to reach them
- Next 2-3 actions

Then start on the first action, unless the handoff or live state shows a blocker or a decision the user needs to make.
