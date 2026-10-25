---
name: review-loop
description: "Take a PR through review to ready-to-merge: a cross-provider autoreview before pushing, then Cursor's PR review, verifying each finding, fixing, replying on every thread and resolving it, and repeating until a round is clean. Use when the user says \"review loop\", \"get this reviewed\", \"address the Cursor comments\", or \"get this PR ready to merge\"."
disable-model-invocation: true
license: MIT
---

# Review loop

Two reviewers, at two moments. `autoreview` checks the diff before it's pushed;
Cursor reviews the PR after. This skill runs both and the fix-reply-resolve
loop between them, then hands off to `land-pr`. It never merges by itself.

## 1. Before pushing

Run `autoreview` on the branch (`--base origin/main`) and follow its "After the
review" steps. Skip it for a docs-only change when the user says so.

## 2. Open the PR ready for review

Open or update the PR as ready for review, not draft: Cursor skips drafts.
Push the fixes from step 1 first.

## 3. Make sure Cursor is reviewing

Check the PR's checks and reviews for Cursor. If Cursor hasn't started within a
few minutes of the push, @-mention Cursor's GitHub handle in a PR comment to
request a review (the comment needs the agent footer and the user's approval to
post, like any other).

Wait in the background for Cursor's check to finish on the **current head
commit**. Don't poll in the foreground, and don't merge while it's pending: its
findings land after the merge.

## 4. Collect findings

```bash
~/agents/skills/review-loop/scripts/pr-findings <pr>
```

It prints the head commit, each reviewer's latest summary (flagging one that
reviewed an older commit), every thread that's unresolved or has no reply from
you, including threads the reviewer resolved itself, and the checks.

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
changed. End each with the agent footer. Then:

```bash
~/agents/skills/review-loop/scripts/reply-resolve <pr> replies.json
```

`replies.json` is `[{"thread": "PRRT_…", "comment": 123, "body": "…"}]`, taken
from `pr-findings`. The script refuses a body without the footer. It posts
without the footer hook's prompt, so run it only after the user approved
replying on this PR. Update the PR description if the diff changed.

## 7. Loop, with a cap

Go back to step 3 for the new head. Stop when a round has nothing new at P2 or
above, or after two rounds. Anything left is an accepted tradeoff: say so in
the reply and to the user.

## 8. Hand off

Report: findings fixed, rejected and why, accepted tradeoffs, and anything that
only a deploy or apply can prove. If the user wants it merged, run `land-pr`.
