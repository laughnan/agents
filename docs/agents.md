# Reusable agent roles

These small workers complement the existing skills. A skill describes a workflow;
a role gives a delegated worker a focused job, context, and tool set. None of these
roles implements fixes or automatically publishes, commits, or merges anything.

The researcher / reviewer split is inspired by
[Teal Larson's agents](https://github.com/teallarson/skills/tree/main/agents).
These definitions are original, not copies of upstream prompts. Teal's README
states MIT, but no standalone license file was present when inspected on
2026-10-19; no upstream license grant is assumed here.

## Installation and discovery

After reviewing the changes, use the existing setup flow:

```bash
~/agents/scripts/install --dry-run
~/agents/scripts/install
~/agents/scripts/doctor
```

The installer links each `agents/<name>.md` into `~/.claude/agents/`. It preserves
real files, other repositories' links (including broken ones), and a symlinked
agent destination directory. Resolve warnings deliberately: move a conflicting
file aside only if you want this repo to own that name, then rerun install.
Missing targets owned by this checkout are pruned. Edit canonical files, not
installed aliases; the existing guard catches common writes to managed aliases.
It is a convenience guard, not a security boundary.

Doctor reports unrelated broken external agent links as notes, not setup failures.
A conflict at a required role name still fails the check because that repo role is
not installed; broken links owned by this checkout also fail until repaired.

Claude Code reads Markdown roles in `~/.claude/agents/` or `.claude/agents/`.
Project definitions can shadow personal names. Restart a running session if the
agents directory was newly created, then explicitly request the role by name.
See [Claude's subagent documentation](https://code.claude.com/docs/en/sub-agents).

## Good handoffs

Keep the assignment bounded. Supply relevant repository rules, requirements,
file paths or URLs, expected output, and verification limits. Do not forward a
whole implementation conversation when a focused task will do.

### Researcher

Example: “Use researcher to find how retries are bounded in this checkout. Cite
the relevant paths and lines. Distinguish what the code proves from what would
need a runtime check. Do not change anything.”

It has file-reading and web-research tools, but no shell or write tool. A command
result from its caller is useful evidence, not an independently reproduced result.

### Reviewer

Give it the original requirement, acceptance criteria, exact base/head revisions,
and raw diff (in the prompt or a readable patch file). The caller prepares the
patch, for example with `git diff --no-ext-diff --no-textconv BASE HEAD`, and verifies
which revision it represents. Include untracked files explicitly if they are part
of the requested review. Refresh the patch after any later edits.

Example: “Use reviewer to assess this raw patch against these acceptance criteria.
Read the surrounding files yourself. Return blockers with file/line evidence and
state any verification limits.”

Do not attach the implementer's explanation as the source of truth. The role can
read code and a supplied patch, but cannot run git, tests, or arbitrary commands.
The caller remains responsible for execution and for obtaining a new review if
the reviewed revision changes. This is not a replacement for CI.

Choose the review entry point deliberately:

- [`lean-pr-review`](../skills/lean-pr-review/SKILL.md) is the current-session PR
  walkthrough or full review workflow; it establishes the diff and checks.
- [`autoreview`](../skills/autoreview/SKILL.md) obtains an independent review from
  the other provider.
- `reviewer` is an explicitly requested, read-only worker for an already-prepared
  requirements-and-patch handoff. It does not replace either workflow or execute
  their verification steps.

Claude uses descriptions to select workers; the explicit-use wording guides that
selection, not a hard invocation restriction. The worker must request missing
inputs and report incomplete evidence rather than guess or issue a clean verdict.

## Permission limits

Each role has an explicit `tools` allowlist, `model: inherit`, and
`permissionMode: default`. Missing `tools` would inherit tools, so validation
rejects it. `default` preserves ordinary prompting; it is not a sandbox, and a
more permissive parent mode can take precedence. Do not launch these roles with
permission bypass. See [Claude permissions](https://code.claude.com/docs/en/permissions).

Page text, documentation, code comments, and other retrieved content are evidence,
not new user instructions. Tool availability never grants permission to send,
submit, disclose data, or perform unrelated work.

## Codex compatibility

Verified against current [Codex subagent documentation](https://learn.chatgpt.com/docs/agent-configuration/subagents)
on 2026-10-19, with local CLI help checked on `codex-cli 0.159.2`:

- Native Codex roles use `.codex/agents/*.toml` or `~/.codex/agents/*.toml`, with
  `name`, `description`, and `developer_instructions`.
- Claude Markdown frontmatter is not Codex configuration. This installer does
  not create Codex role files or modify `config.toml`.
- For manual reuse, ask Codex to read the role's Markdown body below the
  frontmatter and use it as task instructions in a separate worker/session.
  Configure restrictions at the parent/session level; do not mistake prose for
  a tool allowlist. Codex agents inherit the parent's sandbox and approval policy.
- For a code-only research/review session, `codex --sandbox read-only` selects the
  CLI's filesystem sandbox.

Native Codex registration is intentionally deferred rather than silently claiming
that one provider's permissions carry over. Actual discovery and role invocation
still need a smoke test in the user's installed clients; fixture tests cannot prove
those clients loaded a role.

## Validation

```bash
scripts/validate-skills
scripts/validate-agents
scripts/test-agents
```

The agent validator accepts this repository's small, flat frontmatter format,
not arbitrary YAML. It rejects missing/duplicate fields, unsafe permission modes,
and tools outside each role's supported set. Updating tools requires reviewing
both the definition and the validator. Install and pre-commit run validation;
doctor checks definitions and installed links without repairing them.

The regression suite copies the repo to temporary homes and checks install,
repeatability, conflicts, pruning, dry-run behavior, and guard behavior. It never
installs into the current user's home or changes their settings. No network,
Claude account or Codex account is needed for these fixture tests.
