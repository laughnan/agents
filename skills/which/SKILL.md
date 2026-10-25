---
name: which
description: "Router over Alex's personal skills: given what the user is trying to do, name the skill or chain of skills that fits and hand back the exact prompt to type. Use for /which, 'which skill', 'what should I use for', or 'where do I start'."
disable-model-invocation: true
license: MIT
metadata:
  source: https://github.com/mattpocock/skills/tree/main/skills/engineering/ask-matt
---

# Which

Find out what the user is trying to do, then point at the skill (or chain) that
fits. Don't do the work yourself. If the goal is unclear, ask one question first.

Reply with: the skill or chain, one sentence on why, and a ready-to-type prompt
such as `/diagnose the export job times out on accounts with >10k rows`. If
nothing fits, say so; don't stretch a skill to cover it.

## Map

**Starting and stopping a session**
- `pickup`: resume work; reads the last handoff, git state, PR and CI.
- `handoff`: stop cleanly; writes a handoff to scratch for the next session.
- `ketchup`: plain-words catch-up on what happened in this chat since you last looked.

**Understanding code**
- `how`: how a subsystem works, at onboarding depth.
- `why`: why it was built this way; digs through git, tickets, docs, chat.
- `teach`: walk me through it until I actually understand it; runs `how` and `why`, explains plainly.
- `bro`: ELI5. Restate the last message with no jargon, or `/bro <topic>` to explain a topic from scratch.
- `blast-radius`: what a small-looking change could break elsewhere, proven by running code.

**Planning**
- `in-your-own-words`: play back the goal and the problem in your own words, then wait. On a confirm, point at the next skill.
- `grill`: stress-test a vague plan until every decision is pinned down.
- `to-spec`: turn the conversation into a spec on the tracker.
- `to-tickets`: break a spec or plan into vertical-slice tickets with dependencies.

**Building and fixing**
- `tdd`: build or fix test-first in red-green slices.
- `diagnose`: hard bugs and perf regressions: reproduce, minimise, hypothesise, instrument, fix.
- Principles the agent applies on its own: `principle-fix-root-causes`,
  `principle-prove-it-works`, `principle-subtract-before-you-add`.

**Reviewing and shipping**
- `lean-pr-review`: walk a PR by concern, separate design advice from bugs, and give a verdict at the reviewed head.
- `autoreview`: independent review by the other provider (Claude to Codex or back).
- `review-loop`: autoreview before pushing, then Cursor's PR review: fix, reply on and resolve every thread, repeat until clean.
- `land-pr`: rebase, full check gate, merge, verify MERGED.

The `reviewer` agent is not a slash-command workflow: explicitly request it only
for a read-only assessment of supplied requirements, exact revisions, and a raw
patch. Use `lean-pr-review` for the PR walkthrough and `autoreview` for the other
provider's independent review. See [role handoffs](../../docs/agents.md#reviewer).

**Improving the setup**
- `retro`: after a session, propose improvements to rules, checks, and skills.
- `capture-learnings`: turn review feedback and corrections into durable rules.
- `agent-config`: change settings, hooks, global rules, or skills in `~/agents`.

**Writing**
- `meaning-first`: draft or revise prose (emails, memos, posts) so it reads clearly and not like an LLM.

## Common chains

| Situation | Chain |
|---|---|
| Fuzzy idea to shipped feature | `grill` → `to-spec` → `to-tickets` → `tdd` per ticket → `autoreview` → `land-pr` |
| Bug report | `diagnose` → `autoreview` → `land-pr` |
| "Walk me through this PR" | `lean-pr-review`; add `autoreview` when you want an independent second opinion |
| "Is this small change safe?" | `blast-radius`, then `autoreview` for a second opinion |
| Changing unfamiliar code | `how` → `why` → then build |
| "I don't get it" | `teach` for depth, `bro` for ELI5 |
| "Play back what you think I want" | `in-your-own-words` → `grill`, `diagnose`, or `tdd` |
| End of day / switching laptops | `handoff`, then `pickup` in the next session |
| PR is open and needs review to merge | `review-loop` → `land-pr` |
| Reviewer left lots of comments | fix them, then `capture-learnings` |
| The agent keeps making the same mistake | `retro` or `capture-learnings`, then `agent-config` to apply |
