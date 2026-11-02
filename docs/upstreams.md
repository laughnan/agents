# Upstreams

The last commit read from each repo our skills adapt (see `NOTICE` and each
skill's `metadata.source`). On the next sync, review
`git log <commit>..HEAD -- <paths>` for each repo, then update this table.

| Repo | Last read | Date |
|---|---|---|
| [cursor/plugins](https://github.com/cursor/plugins) (`pstack/`) | `ae5650febf4320793844c12c4adaa937f417f8da` | 2026-10-31 |
| [mattpocock/skills](https://github.com/mattpocock/skills) | `4ae2317ddb22b046e26455e4f9c9b3aaaf62212d` | 2026-10-31 |
| [steipete/agent-scripts](https://github.com/steipete/agent-scripts) | `d210c0a77c8f9ae5e1d939b13238a75e87cdb69a` | 2026-10-30 |
| [openclaw/agent-skills](https://github.com/openclaw/agent-skills) | `a2180a0224c2102ace57254ef0ce3f760d482d45` | 2026-11-01 |

## Not yet adopted

Upstream changes reviewed at the commits above and left for a later decision:

- `principle-fix-root-causes`: pstack reframed "never add guards" as "a guard
  is a fix only when the state it handles is legitimate", and added "propose
  a cheap always-on signal after a deep dig" (e5136d8, 36cecbf).
- `ketchup`: pstack added before/after visuals, a /bro voice, and "never cut
  items to stay under a word count" (ea32d95 through bc14437). Ours stays
  text-only on purpose.

Adopted at these commits: pstack `sharpen` and `statechart`. `statechart`
vendors upstream's `scripts/` as `tool/`, without its test suite; when syncing,
copy the new `scripts/` over `tool/` and drop `test/` again.

Reviewed and skipped: pstack `how`/`why` model-routing changes (Cursor-only),
steipete `codex-first` and release tooling, openclaw `autoreview` CLI fixes
(our skill calls the CLI directly, not their scripts). New and not adopted:
pstack `ketchup-video` and the formal-verification skills, Matt's
`software-factory` (in progress upstream).
