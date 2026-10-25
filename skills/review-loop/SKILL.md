---
name: review-loop
description: "Take a PR through review to ready-to-merge: a cross-provider autoreview before pushing, then Cursor's PR review, verifying each finding, fixing, replying on every thread and resolving it, for up to two rounds. Use when the user says \"review loop\", \"get this reviewed\", \"address the Cursor comments\", or \"get this PR ready to merge\"."
disable-model-invocation: true
license: MIT
---

# Review loop

Two reviewers, at two moments. `autoreview` checks the diff before it's pushed;
Cursor reviews the PR after. This skill runs both and the fix-reply-resolve
loop between them. It never merges: landing is the user's `/land-pr`.

`autoreview` and `land-pr` are user-invoked skills, so you can't hand off to
them. Run `autoreview`'s script yourself and follow its SKILL.md; ask the user
to type `/land-pr`.

## 1. Before pushing

```bash
~/agents/skills/autoreview/scripts/autoreview --focus "<the spec or risk>"
```

With no target it reviews against the PR's base, or `origin/main`, which is
right for stacked branches too. Then follow the "After the review" steps in
`~/agents/skills/autoreview/SKILL.md`. Skip this step for a docs-only change
when the user says so.

## 2. Open the PR ready for review

Open or update the PR as ready for review, not draft: Cursor skips drafts.
Push the fixes from step 1 first.

## 3. Make sure Cursor is reviewing

Cursor is reviewing when its check is running on the PR, or when `pr-findings`
(step 4) shows a review from Cursor of the current head. If neither appears a
few minutes after the push, request one with a top-level PR comment whose first
line is `cursor review`. Post it with the user's `gh` login: Cursor ignores
comments from bots and apps, and @-mentions don't start a review. Like any
comment, it needs the agent footer and the user's approval. If Cursor still
doesn't start, ask the user to post `cursor review` themselves.

Wait in the background until Cursor has reviewed the **current head commit**.
Don't poll in the foreground, and don't merge before then: its findings would
land after the merge.

## 4. Collect findings

```bash
~/agents/skills/review-loop/scripts/pr-findings <pr>
```

It prints the head commit, each reviewer's latest summary (flagging one that
reviewed an older commit), every thread that's unresolved or has no reply from
you, including threads the reviewer resolved itself, and the checks. It exits
non-zero if it couldn't read everything.

## 5. Triage

Follow `autoreview`'s "After the review" rules for each finding:

- Read the cited code. Fix what's real.
- Reject with evidence what isn't, and say why in the reply.
- The reviewer can't see production or credentials. Treat claims about live
  state (deployed versions, DNS, API behavior) as questions: check them before
  fixing or rejecting.
- A finding that's a warning about a future edit, not a defect, gets a reply
  and no change.

Commit the fixes, run the repo's checks, and push.

## 6. Reply and resolve

Write one reply per thread, naming the commit that fixed it or why nothing
changed. End each body with a blank line and then the agent footer. Then:

```bash
~/agents/skills/review-loop/scripts/reply-resolve <pr> replies.json
```

`replies.json` is `[{"thread": "PRRT_…", "comment": 123, "body": "…"}]`, taken
from `pr-findings`. The footer hook checks every body and asks the user once
for the batch; the script checks the footer again and exits non-zero if any
reply or resolve fails. Update the PR description if the diff changed.

## 7. Loop, with a cap

Go back to step 3 for the new head. Stop when a round has nothing new at P2 or
above, or after two rounds. Anything left is an accepted tradeoff: say so in
the reply and to the user.

## 8. Hand off

Report: findings fixed, rejected and why, accepted tradeoffs, and anything that
only a deploy or apply can prove. If the user wants it merged, ask them to run
`/land-pr`.
