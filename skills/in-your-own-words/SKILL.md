---
name: in-your-own-words
description: "Restate in your own words what you think the user's goals are and what problem they're trying to solve, then stop so they can confirm or correct the reading. On a confirm, stop or point at grill, diagnose, or tdd. On a correction, play it back once more before anything else. Use for /in-your-own-words, 'in your own words', or 'play back what you think I want'."
disable-model-invocation: true
license: MIT
metadata:
  source: https://github.com/cursor/plugins/tree/main/pstack/skills/in-your-own-words
---

# In your own words

Restate what you think the user wants, in your own words, then stop. They confirm or correct the reading.

With nothing after `/in-your-own-words`, use the task this conversation is about. If they add a topic or paste an ask, use that. Read only enough to understand the request. Don't investigate a cause, design a fix, or edit anything.

## What to say

Two parts. Use your own words. Don't walk their message back line by line, and don't return their sentences with a few words swapped.

- **Goal**: what they want to be true when this is done, and why.
- **Problem**: what is wrong or missing, for whom, and what is different once it is solved. The thing they asked for can be one route to that goal.

Keep their exact words for names (files, errors, fields, products) and for values the reading rests on (amounts, IDs, limits, dates). Mark anything you inferred as a guess. Leave out a part that has nothing in it. When the request is already clear, a few lines are enough.

Don't propose a plan, a fix, or next steps.

Ask at most one question, only about the goal or the problem, and only when the answer would change the work. Say what each answer would change. Don't ask them to restate the request.

## Then stop

End the turn after the playback. Wait for them.

A confirm means the reading is right. Stop, or name the one next skill and stop: `grill` when the plan is still vague, `diagnose` for a bug or a slow path, `tdd` to build or fix. Leave the work to that skill.

A real correction changes the reading. Play the goal and the problem back once more with the correction in it, then stop. Do that before anything else, including when the correction comes with a "go ahead." An answer to the question above is a correction too.
