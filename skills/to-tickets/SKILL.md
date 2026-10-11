---
name: to-tickets
description: "Break a plan, spec, or the current conversation into tracer-bullet vertical-slice tickets with explicit blocking edges, quiz the user on the breakdown, then publish to GitHub Issues, Linear, or local markdown files. Use when the user says \"to tickets\", \"break this into issues\", or \"split this into tasks\"."
disable-model-invocation: true
license: MIT
metadata:
  source: https://github.com/mattpocock/skills/tree/main/skills/engineering/to-tickets
---

# To Tickets

Break a plan, spec, or conversation into **tickets**: tracer-bullet vertical slices, each declaring the tickets that **block** it.

## Process

### 1. Gather context

Work from the conversation. If the user passes a reference (spec path, issue number or URL), fetch it and read the full body and comments.

### 2. Explore the codebase (optional)

If you haven't, explore to understand the current state. Use `GLOSSARY.md` vocabulary (if present) and respect ADRs. Look for prefactoring that makes the work easier: make the change easy, then make the easy change.

### 3. Draft vertical slices

- Each slice cuts a narrow but COMPLETE path through every layer (schema, API, UI, tests), not a horizontal slice of one layer.
- A completed slice is demoable or verifiable on its own.
- Each slice fits in a single fresh context window.
- Prefactoring comes first.

Give each ticket its **blocking edges**: the tickets that must finish before it can start. No blockers means it can start now.

**Wide refactors are the exception.** One mechanical change (rename a column, retype a shared symbol) that breaks call sites across the codebase can't land as a green vertical slice. Sequence it **expand-contract**:

1. Expand: add the new form beside the old so nothing breaks.
2. Migrate call sites in batches sized by blast radius (per package, per directory), each batch a ticket blocked by the expand. CI stays green because the old form still exists.
3. Contract: delete the old form in a ticket blocked by every migrate batch.

If even the batches can't stay green alone, keep the sequence but have them share an integration branch, all blocking a final integrate-and-verify ticket; green is promised only there.

### 4. Quiz the user

Present the breakdown as a numbered list. For each ticket: **Title**, **Blocked by**, **What it delivers** (the end-to-end behavior it makes work). Ask:

- Is the granularity right (too coarse / too fine)?
- Are the blocking edges correct: does each ticket depend only on tickets that genuinely gate it?
- Should any be merged or split?

Iterate until the user approves.

### 5. Publish

Check the repo's `AGENTS.md` / `CLAUDE.md` for which tracker is used; if it doesn't say, ask. Show the final ticket content and get a yes before creating anything remotely. Publish in dependency order (blockers first) so later tickets can reference real identifiers.

- **GitHub Issues**: one `gh issue create --title "<title>" --body-file <file>` per ticket. Add `--label` only for labels that already exist (`gh label list`). Put blockers in the "Blocked by" section as `#<number>`. If the source was an existing issue, reference it under "Parent".
- **Linear**: only if a Linear MCP server is connected; use its issue-creation tool, and its native blocking / parent relations if it exposes them, otherwise the "Blocked by" section.
- **Local files** (fallback): one file per ticket at `tickets/<feature-slug>/<NN>-<slug>.md` (or the repo's existing location), numbered from `01` in dependency order. Never one combined file.

Do NOT close or modify any parent issue. Report the created URLs or paths, and which tickets are on the frontier (all blockers done) to start with.

## Ticket template

```markdown
# <NN>: <Title>          (local files only; on a tracker, this is the issue title)

## Parent
<reference to the parent issue, if any; otherwise omit>

## What to build
The end-to-end behavior this ticket makes work, from the user's perspective,
not a layer-by-layer implementation list.

## Acceptance criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Blocked by
- <ticket reference>, or "None (can start immediately)".
  Omit when blockers were set as native tracker links.
```

No file paths or code snippets; they go stale fast. Exception: a prototype snippet that encodes a decision more precisely than prose (state machine, schema, type shape); inline the decision-rich part and note it came from a prototype.
