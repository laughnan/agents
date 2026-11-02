---
name: grill
description: "Relentless round-by-round interview that stress-tests a plan, design, or idea until every vague part is pinned down, optionally recording settled terms and decisions in GLOSSARY.md / ADRs. Use when the user says \"grill me\", \"stress-test this\", \"poke holes in my plan\", or \"interview me about this\"."
disable-model-invocation: true
license: MIT
metadata:
  source: "https://github.com/mattpocock/skills/tree/main/skills/productivity/grill-me, https://github.com/mattpocock/skills/tree/main/skills/productivity/grilling, https://github.com/mattpocock/skills/tree/main/skills/engineering/grill-with-docs, https://github.com/mattpocock/skills/tree/main/skills/engineering/domain-modeling"
---

# Grill

Interview the user relentlessly until you reach a shared understanding. Map the plan as a **design tree**: every decision branches into the decisions that hang off it.

## Rounds

The **frontier** is every decision whose prerequisites are already settled: questions you can ask now without guessing at answers you haven't heard. Ask the whole frontier in one round, numbered, each with your recommended answer. Then wait.

```
**Q1 - <question title>**: <question body; may include options>

Recommended: <your answer>

---

**Q2 - <question title>**: ...

Recommended: <your answer>
```

Word each question so "yes" accepts your recommendation.

Each round reshapes the tree: settled decisions push the frontier outward. Recompute and ask the next round. A question that depends on another question still open in this round belongs to a later round.

Press on vagueness. "It should be fast", "handle errors gracefully", "users" and "later" are not answers: ask for the number, the behavior, the actor, the date. Name assumptions you would otherwise make silently and put them to the user.

Test boundaries with concrete scenarios. When the plan relates two concepts, invent an edge case that forces a precise answer: "An order ships in two parts and one is returned. Is the order cancelled, refunded, or neither?"

## Facts vs decisions

Finding **facts** is your job. If a question needs a fact from the environment (code, config, docs, tools), look it up yourself, or dispatch a sub-agent with a fresh context window (not a fork of this conversation) if your harness supports one; never ask the user for something you could find. Don't block on it: only questions downstream of a pending lookup wait; ask the rest now.

When the user states how something works, check the code. If it disagrees, put the contradiction to them: "You said partial cancellation is possible, but the code cancels whole orders. Which is right?"

**Decisions** are the user's. Put each to them and wait.

## Docs (only if the repo already has them)

If the repo has a `GLOSSARY.md` or an ADR directory (e.g. `docs/adr/`, `adr/`, `docs/decisions/`):

- Use glossary terms in your questions. When the user uses a term that conflicts with or is missing from the glossary, ask which meaning they intend.
- As terms get pinned down, propose glossary additions/edits: the term, a one- or two-sentence definition of what it is, and the synonyms to avoid. Only terms specific to this project; no implementation details.
- When a decision is hard to reverse, has real alternatives, and a future reader would ask "why?", propose an ADR in the repo's existing format and numbering. A paragraph is enough: the context, the decision, and why.
- Show proposed doc changes and get a yes before writing. Don't create these files in a repo that doesn't have them unless the user asks.

## Done

The session ends when the frontier is empty: every branch visited, nothing silently assumed. Summarise the settled decisions. If the repo has no `GLOSSARY.md` and the session pinned down project terms worth keeping, offer once to start one so the next session doesn't re-learn them. Do not act on the plan until the user confirms you have reached a shared understanding.
