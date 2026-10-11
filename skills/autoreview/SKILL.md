---
name: autoreview
description: "Get an independent code review from the other provider: Claude Code hands the diff to Codex, Codex hands it to Claude. Use for 'autoreview', 'second opinion', 'have codex review this', 'have claude review this', or before opening or landing a PR."
disable-model-invocation: true
license: MIT
metadata:
  source: https://github.com/openclaw/agent-skills/tree/main/skills/autoreview
---

# Autoreview

A different model reviewing your work catches what you are blind to. This skill
runs the other provider's CLI in read-only mode against the diff and brings back
findings. You then verify them; the reviewer advises, it does not decide.

## Run

```bash
~/agents/skills/autoreview/scripts/autoreview [target] [--focus "..."]
```

| Target | Flag | Reviews |
|---|---|---|
| default | (none) | dirty tree: uncommitted; clean: branch vs PR base or `origin/main` |
| local work | `--uncommitted` | staged, unstaged, and untracked |
| branch / PR | `--base <ref>` | merge-base to HEAD |
| one commit | `--commit <sha>` | that commit |

Direction is automatic: from Claude Code the reviewer is Codex, otherwise Claude.
Override with `--reviewer codex|claude` only when the user asks or the default CLI
is missing (say which failure made you switch). `--model` picks the reviewer model.

Pass `--focus` with what the reviewer can't infer: the spec or ticket, the risky
part, what you already ruled out. Don't pass your own conclusions about safety.

Reviews take minutes. Run it in the background if the harness supports that.

## After the review

1. Verify each finding against the code before acting. Read the cited lines; if
   cheap, reproduce it.
2. Fix what is real and likely, or rare but severe (data loss, security, money).
3. Skip theoretical races and recoverable edge cases whose fix adds outsized
   complexity; say so explicitly as an accepted tradeoff.
4. Report back: findings fixed, findings rejected and why, accepted tradeoffs.

Don't rerun the review to fish for a clean result. Rerun once after substantial
fixes if the user wants confirmation.
