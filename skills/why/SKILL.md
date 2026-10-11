---
name: why
description: "Investigate why code is shaped the way it is: design rationale, tradeoffs, regressions, magic numbers. Queries every available evidence source (git/gh, tickets, docs, chat, observability, errors, analytics) for a cited, confidence-tiered answer. Use for 'why does X work this way', 'why did we pick Y'."
license: MIT
metadata:
  source: https://github.com/cursor/plugins/tree/main/pstack/skills/why
---

# Why

Investigate the motivation behind code. `how` answers what the code does. `why` answers what forces led to its shape.

Work like a careful, cautious, precise investigator. Code shows what it does, not why it exists. The why lives in commits, PRs, tickets, docs, and conversations, all incomplete and sometimes contradictory. A confident answer on weak evidence is the exact failure this skill exists to prevent.

## 1. Pin the target and the question

The target is a chunk of code, a pattern, a feature, or a named decision. The question is a rationale, a tradeoff, a motivating edge case, an external constraint, dead code, or a history sweep. If the target is vague, pick the best guess from context (open files, recent edits, what was just discussed), state it in one line, and proceed.

If the user embeds a hypothesis ("I assume it's for performance?"), treat it as one candidate to check, not a conclusion to confirm.

## 2. Build the code anchor

Before fanning out, gather the seed context yourself:

```bash
git blame -L <start>,<end> <file>          # last-touch commits
git log --follow --oneline -- <file>       # history through renames
git log -S '<exact string>' -- <file>      # commits that added/removed this text
git log -1 --format=%B <hash>              # PR numbers "(#1234)", ticket IDs
gh pr view <n> --json title,body,author,createdAt,mergedAt,labels,closingIssuesReferences,comments,reviews
```

The anchor is: file paths and line ranges, key symbols, the substantive commits (most recent first), PR numbers, and ticket IDs. Every investigator gets it. Don't stop at the latest commit. The current shape is often the accretion of earlier decisions, so trace back to where the pattern originated.

## 3. Discover sources, then investigate each one

**Discover at run time.** List the MCP servers and CLIs actually available in this session (the tool list, configured MCP servers, and vendor CLIs on `PATH`; check with `command -v <name>`). Do not assume a tool exists; do not invent tool names. If a source needs auth and fails, record it as a gap and move on.

Map each available source to one evidence category:

| Category | Examples | Best at |
|---|---|---|
| Source control | git, `gh` (always available) | rationale captured during review |
| Issue tracker | Linear, Jira, GitHub Issues | the product or business forcing function |
| Long-form docs | Notion, Confluence, Google Docs | design rationale written before the code |
| Team chat | Slack, Teams, Discord | deliberation that never reached a doc |
| Infra observability | Datadog, Grafana, Honeycomb | the runtime signal behind timeouts, retries, limits |
| Error tracking | Sentry, Rollbar, Bugsnag | the exceptions that motivated defensive code |
| Analytics warehouse | Databricks, Snowflake, BigQuery | data behind thresholds, flags, migrations |

**Investigate every category that has a source.** Default to full coverage: document the null, don't skip the search. If your harness supports subagents, spawn one per category in parallel, each owning exactly one source, with the brief below. Otherwise work through the categories yourself in turn. Per-category search tactics are in `references/sources.md`.

If the target looks defensive (null checks, retries, timeouts, rate limits, feature flags, OOM handlers), also hunt for incident history in every source (see the incident section of `references/sources.md`).

Skip a category only with a written reason that goes in Sources Consulted: no source available (a gap, not a choice), or provably irrelevant (e.g. error tracking for a build-time script). Answering inline from one PR body is allowed only when it fully answers the question and you say so.

### Investigator brief

Give each investigator: the question, the code anchor, its one assigned source, and these rules.

- Cast a wide net first, then narrow. Read each PR, ticket, doc, or thread in full; the evidence is often in a comment or reply.
- Follow links within your source only. Record cross-source references as leads for that source's investigator.
- Quote verbatim with an exact location (PR #, ticket ID, URL, permalink, commit hash, `file:line`), plus author and date.
- Record what you searched, verbatim. An empty search is a finding.
- Mechanics are not motivation. A diff from `50` to `100` shows the change, not the reason. Never infer intent from code style or names.
- Record contradictions; don't resolve them. Gather, don't conclude.
- Return: Source, What I Searched, Direct Evidence, Circumstantial Evidence (with alternative readings), Contradictions, Gaps, Leads.

## 4. Synthesize

Merge all findings (including nulls and skipped categories) yourself, or hand them to one synthesizer subagent. Merge duplicate citations. Spot-check any citation you doubt by opening it. Surface contradictions instead of picking the tidier story. Do not write files or change external state during the investigation.

### Confidence tiers

Every claim sits in exactly one tier, which sets its section and phrasing.

1. **Direct.** Someone wrote why, explicitly: a PR body, ticket, comment, doc, or chat message. Phrase plainly and cite: "This exists because X [PR #123]."
2. **Supported.** Several indirect items converge. Cite each: "The evidence points strongly to X: A, B, C."
3. **Inferred.** A reasonable reading nothing states. Hedge and show the chain: "Given A and B, C seems likely."
4. **Speculative.** Plausible on thin evidence, other stories fit equally. "One possibility is X, but we found no direct evidence."
5. **Unknown.** You looked and could not find out. Say exactly where and what you searched.

"Because", "the reason is", "was designed to", "fixes", and "the team decided" require an adjacent citation. Use hedges ("appears to", "likely", "suggests", "is consistent with") for inferences. Avoid "obviously", "clearly", "of course", "just", and "I think". Don't retrofit a clean rationale onto messy history, don't assume a consistent pattern was intentional (it may be copy-paste), and don't turn absence of evidence into evidence of absence.

## 5. Present

Use this structure. Keep the confidence language intact when editing.

- **The Question.** One or two sentences.
- **The Code in Question.** Paths, line ranges, symbols.
- **What We Found.** `[Direct]` and `[Supported]` claims, each cited with a short quote.
- **What We Can Reasonably Infer.** `[Inferred]` claims with the reasoning visible. Skip if empty.
- **Competing Hypotheses.** Each with evidence for and evidence against or missing. Skip if one clear answer.
- **What We Don't Know.** Specific gaps: the queries run, sources unavailable and why, and who would likely know. If this is empty, be suspicious.
- **Sources Consulted.** One line per category, including ones that returned nothing or were skipped, with the reason.
- **Confidence Summary.** One or two sentences.

If the question is a precursor to changing the code, end with a **Preserve / Change / Avoid / Risk** constraint set derived from the findings.

Before returning, check: every Found claim has a citation (or moves down a tier); phrasing matches tier; no contradiction was quietly dropped; no code is cited as evidence of its own intent; the user's embedded hypothesis was tested, not rubber-stamped. The value of this output is its honesty, not its authority.
