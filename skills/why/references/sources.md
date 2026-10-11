# Source tactics

Concrete search moves per evidence category. Tool names vary by server; inspect the available tool schema before calling anything, and adapt these moves to whatever source in the category is present.

## Source control (git, gh)

- Expand the seed: `git log --follow -p -- <file>`, `git log -S '<string>'` or `-G '<regex>'`, `git show <hash>`.
- For each substantive commit, read the PR body, review comments, and linked issues (`gh pr view <n> --json ...,comments,reviews,files`). Review threads hold the real debate.
- In-repo: ADRs (`rg -l -i 'architecture.decision' --glob '*.md'`), TODO/FIXME/HACK near the target, tests that name the edge case, CHANGELOG entries, files co-changed in the same commits.
- Pitfalls: squash merges lose branch commits (fall back to the PR); "small refactor" can hide a behavior change (read the diff); cargo-culted patterns (find the commit where it first appeared); bot commits carry no intent.

## Issue tracker (Linear, Jira, GitHub Issues)

- Fetch ticket IDs from the anchor first; read description and all comments.
- Keyword search on feature name, symbols, business terms. Walk sub-issue to parent; parents carry the why. Read attached project docs or specs.
- Labels (`customer-request`, `incident-followup`, `compliance`, `perf`) and milestones hint at the forcing function.
- Pitfalls: scope drift on reopened tickets, boilerplate "Why" sections, stale plans (compare dates to ship date), duplicate chains.

## Long-form docs (Notion, Confluence, Google Docs)

- Search feature name, symbols, author names, error strings, user-visible terms; bound by ship date when known.
- Fetch full pages, not previews. Follow child pages ("alternatives considered") and meeting notes.

## Team chat (Slack, Teams, Discord)

- Search the PR author's messages around the merge date; the PR URL or `/pull/<n>`; feature name and casual phrasings; handled error strings.
- Narrow to likely channels: engineering, project, incident, owning team.
- Always fetch the full thread. Note retention cliffs and that DMs are usually unsearchable. A joke is not a decision.

## Infra observability (Datadog, Grafana, Honeycomb)

- Find the owning service and its dependencies. Check dashboards and monitors covering the target; a monitor threshold is often the answer to "why N?".
- Pull metrics around the add/change date. A spike days before the merge is strong support. Look for formal incident records.

## Error tracking (Sentry, Rollbar, Bugsnag)

- Search by the exception classes, messages, function names, and file path the target handles.
- Check first seen, last seen, affected releases, and frequency trajectory. Does the error stop at the release that shipped the target?

## Analytics warehouse (Databricks, Snowflake, BigQuery)

- Probe schemas before trusting table names (`SHOW TABLES ... LIKE`, `DESCRIBE`). Read-only queries only. Time-bound every query (about 30 days either side of the ship date).
- Useful shapes: event volume stepping up or decaying around the merge; the p99 of a property just before the PR matching a threshold constant; flag or experiment exposure by variant; query history for the expensive queries behind a migration or perf rewrite.

## Incidents (cross-cutting)

Use when the target looks defensive. In every source, look for postmortems, `sev-*`/`incident-*` channels and labels, commits like "fix for incident" or revert then re-apply, incident records, errors whose window ends at the ship date. When you find an incident link, read the full postmortem; its action items often map to the code. Corroboration across sources (incident ID in a ticket, linked in a doc, discussed in chat, pointing at the PR) is the strongest evidence this skill can produce.
