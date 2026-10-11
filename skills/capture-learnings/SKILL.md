---
name: capture-learnings
description: "Extract durable, non-obvious lessons from PR review feedback or a session with corrections and write them where future agents will read them: the repo's AGENTS.md or rules files, or ~/agents/AGENTS.md for personal cross-repo rules. Use for 'capture learnings', 'save what we learned', 'remember this for next time'."
disable-model-invocation: true
license: MIT
metadata:
  source: original
---

# Capture Learnings

Turn corrections into rules so the same mistake does not happen twice. Most of a session is not worth keeping. Keep only what a future agent would get wrong without being told.

## 1. Gather the signal

- **PR feedback.** If there is a PR, pull human review comments and PR-level reviews. Skip bot noise (CI, deploy previews, ticket linkers).
  ```bash
  gh pr view <n> --json reviews,comments,files
  gh api repos/{owner}/{repo}/pulls/<n>/comments --jq '.[] | {path, author: .user.login, body}'
  ```
- **Session corrections.** Scan this conversation for moments the user corrected you, redirected you, rejected an approach, or repeated an instruction.
- **Surprises.** Commands, conventions, or behaviors that differed from what you assumed and cost time.

## 2. Filter hard

Keep a lesson only if all hold:
- **Durable.** Still true next month, not tied to this one bug or branch.
- **Non-obvious.** A competent agent would not do it by default, or it contradicts generic best practice.
- **Adopted.** The correction was actually applied in the code or accepted by the user. Drop reviewer suggestions that were not taken, opinions without consensus, and temporary workarounds.
- **Actionable.** It can be written as "do X" or "don't do Y, because Z".

If nothing survives, say so and stop. That is a fine outcome.

## 3. Verify against reality

For repo conventions, confirm the pattern in the current code (read the files, grep for usage). Do not record an aspirational pattern as a current convention. For tool or command facts, confirm by running or reading docs.

## 4. Route each lesson

| Lesson is about | Write it to |
|---|---|
| This repo's code, commands, layout, or conventions | The repo's existing agent instructions: `AGENTS.md`, `CLAUDE.md`, or its rules directory (whatever the repo already uses; nearest-scoped file if nested ones exist) |
| How the user wants you to work, across all repos | `~/agents/AGENTS.md` |
| A recurring check a lint, test, or script could enforce | Propose the mechanism instead of (or alongside) prose |

If the repo has no agent instruction file, ask before creating one. Prefer adding to an existing section over creating a new file.

## 5. Write it

- Read the target file first. Don't duplicate; tighten or replace an existing line if it is close.
- One or two lines per lesson, imperative, with the reason when it isn't self-evident. Add a minimal example only when it removes ambiguity.
- Match the file's existing tone and format. Keep files short; agents skim.
- If a lesson replaces an old rule, delete the old one.
- Run the repo's markdown formatter if it has one.

## 6. Report

List each lesson, where it went, and anything you dropped and why. Do not commit unless asked. If you wrote to `~/agents/AGENTS.md`, remind the user that `~/agents` is a git repo and the change needs a commit there to persist across machines.
