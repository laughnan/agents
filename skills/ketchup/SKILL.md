---
name: ketchup
description: "Catch the user up on everything in this chat since their last message, in plain words, with an executive summary for each action item so they can make the call. Use for /ketchup, 'catch me up', 'what did I miss', or 'where are we'."
disable-model-invocation: true
license: MIT
metadata:
  source: https://github.com/cursor/plugins/tree/main/pstack/skills/ketchup
---

# Ketchup

Catch the user up on everything in this chat since the last message they wrote before `/ketchup`. Notifications and subagent results are not their messages. Assume the user remembers their last message and nothing after it. Call each PR, branch, or agent by a name they would know, not by a label you invented during the work.

Write plainly: short sentences, everyday words, no jargon you did not need, no hedging filler. Do not restate their question back to them.

## Gather what changed

Keep this turn read-only. Collect your own work since that message, reports from subagents, and messages from anyone else in this chat. Check the current state of each PR, CI run, or agent this chat touched. Say which are still running and which you could not check.

An action item is a decision or step only the user can take, such as a product choice, an approval, an irreversible action, or access you lack. Include any still waiting on the user, even one raised before their last message. Work you can still do yourself is not an action item.

## Write the reply

Open with one sentence that says how many action items there are, or that there are none. If nothing happened and nothing waits on the user, say so and stop.

Then say what happened, most important first. Give each result and what it means for the user. Skip steps that changed nothing. Name in one line any work left that you can do yourself.

Then give each action item a short executive summary. Cover the decision to make, why it matters now, the options and what each costs, your recommendation, and what happens if the user does not answer. If you do not know a part, say so instead of guessing. Link to the detail when there is one, and write the summary so the user can decide without opening it.
