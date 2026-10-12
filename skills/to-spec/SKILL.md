---
name: to-spec
description: "Synthesize the current conversation into a spec (problem, solution, user stories, implementation and testing decisions, out of scope) and publish it to GitHub Issues, Linear, Asana, or a local markdown file. No interview. Use when the user says \"to spec\", \"write a spec\", or \"turn this into a PRD\"."
disable-model-invocation: true
license: MIT
metadata:
  source: https://github.com/mattpocock/skills/tree/main/skills/engineering/to-spec
---

# To Spec

Turn the current conversation and codebase understanding into a spec. Do NOT interview the user; synthesize what you already know. (If the plan is still vague, suggest `grill` first.)

## Process

1. **Explore** the repo if you haven't. Use the domain vocabulary from `GLOSSARY.md` (if present) and respect ADRs in the area.

2. **Sketch the test seams.** Prefer existing seams to new ones, and the highest seam possible. If new seams are needed, propose them as high as you can. Fewer is better; the ideal is one. Check with the user that the seams match their expectations.

3. **Write the spec** with the template below.

4. **Pick the tracker** (see Tracker), show the user the full spec and the destination, and publish only after they confirm.

## Tracker

Check the repo's `AGENTS.md` / `CLAUDE.md` for which tracker is used, then the global rules (Arcade work: the repo's tracker; personal work: Asana). If neither settles it, ask the user, offering what is available:

- **GitHub Issues**: `gh issue create --title "<title>" --body-file <file>`. Add `--label <label>` only for labels the repo already has (check `gh label list`); don't invent labels.
- **Linear**: only if a Linear MCP server is connected in this session; use its issue-creation tool with the team/project the user names.
- **Asana**: only if an Asana connector or tool is available in this session; use its task-creation tool in the project the user names.
- **Local file** (fallback): the repo's existing spec location if it has one, otherwise `docs/specs/<feature-slug>.md`.

Never create anything in a remote tracker without showing the content and getting a yes. Report the resulting URL or path.

## Template

```markdown
## Problem Statement

The problem the user faces, from the user's perspective.

## Solution

The solution, from the user's perspective.

## User Stories

A long, numbered list covering every aspect of the feature:

1. As a <actor>, I want <feature>, so that <benefit>

## Implementation Decisions

Decisions made, e.g.: modules built/modified and their interfaces, technical
clarifications from the developer, architectural decisions, schema changes,
API contracts, specific interactions.

## Testing Decisions

- What makes a good test here (external behavior only, not implementation details)
- The agreed seams and which modules are tested at them
- Prior art: similar tests in the codebase

## Out of Scope

What this spec does not cover.

## Further Notes

Anything else.
```

No file paths or code snippets in the spec; they go stale fast. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose (state machine, reducer, schema, type shape), inline the decision-rich part and note it came from a prototype.
