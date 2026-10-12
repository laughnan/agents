---
name: land-pr
description: "Land a GitHub PR end to end, deferring to the repo's own landing workflow: bring the branch up to date with its base (git-spice when the repo uses it), run the repo's full check gate, push, confirm with the user, merge via gh, and verify the PR state is MERGED (never CLOSED). Use when the user says \"land this PR\", \"land #123\", \"rebase and merge\", or \"ship this PR\"."
disable-model-invocation: true
license: MIT
metadata:
  source: https://github.com/steipete/agent-scripts/blob/main/docs/slash-commands/landpr.md
---

# Land PR

Input: a PR number or URL. If missing, use the PR most recently discussed, else the current branch's PR; if ambiguous, ask.

Goal: GitHub PR state = `MERGED`. Never `CLOSED`.

## 0. Guardrails

- The repo's own guidance wins. Read its `AGENTS.md` / `CLAUDE.md`, rules, and any merge, PR, or release skill first. Where it says how to update, merge, or ship (merge queue, required reviews, no rebasing published branches, a landing skill of its own), do that and use this skill only to fill the gaps.
- Rewrite history only on the PR's own feature branch, and push it with a lease (`--force-with-lease`, which `gs` uses). Never rewrite the base branch, a protected branch, or another person's branch. If the repo forbids rewriting published history, update the branch with `gh pr update-branch "$PR"` (merges base in) instead of rebasing.
- `git status -sb` is clean. If not, stop and ask.
- Stop and ask if the PR is a draft, has conflicts you can't resolve cleanly, or you can't push to its head branch (fork without `maintainerCanModify`).

## 1. Capture context

```sh
PR="<number-or-url>"
gh pr view "$PR" --json number,title,state,isDraft,mergeable,author,baseRefName,headRefName,headRepository,headRepositoryOwner,maintainerCanModify
base=$(gh pr view "$PR" --json baseRefName --jq .baseRefName)
head=$(gh pr view "$PR" --json headRefName --jq .headRefName)
```

## 2. Discover the gate

Find the repo's full check commands (lint, typecheck, build, test, docs), in this order:

1. `AGENTS.md` / `CLAUDE.md` and docs they point to.
2. `Makefile` / `justfile` targets (`check`, `lint`, `test`, `ci`).
3. `package.json` scripts, run with the package manager implied by the lockfile.
4. Language config (`pyproject.toml`, `Cargo.toml`, `go.mod`) and the CI workflow under `.github/workflows/`, which shows what CI actually runs.

If it's still unclear, ask. State the gate commands before running them.

## 3. Update onto base

Check out the branch with `gh pr checkout "$PR"`. Then:

**Spice branch** means `git rev-parse -q --verify refs/spice/data` succeeds and `gs ls` lists `$head`. Don't run `gs ls` before the `refs/spice/data` check; in an uninitialized repo it tries to initialize git-spice. Steps 5 and 8 use the same test.

- **Spice branch:** `gs repo sync` to pull trunk, then `gs branch restack` (`gs br`) to rebase the branch onto its base, or `gs upstack restack` if branches are stacked on it, to restack them too.
- **Otherwise:**

  ```sh
  git fetch origin "$base"
  git rebase "origin/$base"
  ```

Skip this step if the repo forbids rebasing (see guardrails). Resolve conflicts with tight scope. If a resolution is non-obvious, stop and ask.

## 4. Fix and gate

- Make only the fixes needed to land (keep scope tight). Add a regression test when it fits.
- If the repo keeps a `CHANGELOG.md` (or similar) and recent merged PRs update it, add an entry following that convention. Otherwise skip.
- Run the full gate. Everything green before you push.
- Commit any fixes following the repo's commit message convention.

## 5. Push (fork-safe)

For a spice branch, `gs branch submit --nav-comment=false` (`gs bs`) pushes the branch with a lease and updates its PR; use `gs upstack submit --update-only --nav-comment=false` instead if you restacked an upstack. Always pass `--nav-comment=false`: git-spice otherwise posts stack navigation comments on the PRs. Pass `--update-only` to every upstack or stack submit: without it git-spice opens PRs for stacked branches that were never submitted. Both would be publishing on the user's behalf without their approval. Otherwise:

```sh
head_repo_url=$(gh pr view "$PR" --json headRepository,headRepositoryOwner --jq '"https://github.com/" + .headRepositoryOwner.login + "/" + .headRepository.name')
git push --force-with-lease "$head_repo_url.git" "HEAD:$head"
```

For a same-repo PR, `git push --force-with-lease origin "HEAD:$head"` is equivalent. Never push to `$base`. Then wait for CI: `gh pr checks "$PR" --watch`. Don't merge on red.

## 6. Confirm, then merge

Merging is outward-facing. Show the user: PR title and number, base, gate commands and results, CI status, and the merge method. Wait for a clear yes.

Merge method: follow the repo convention (`AGENTS.md`, or what recent PRs used); check what's allowed with `gh repo view --json squashMergeAllowed,rebaseMergeAllowed,mergeCommitAllowed`.

```sh
gh pr merge "$PR" --squash   # or --rebase / --merge
```

Never `gh pr close`.

## 7. Verify

```sh
gh pr view "$PR" --json state,mergedAt,mergeCommit --jq '.state + " @ " + .mergedAt + " " + .mergeCommit.oid'
```

State must be `MERGED`. If it isn't (queued, auto-merge pending, blocked), report exactly what's blocking.

## 8. Sync local

For a spice branch, note every branch stacked directly on it (`gs ls`) before merging; there may be more than one. After merging, `gs repo sync --restack` pulls trunk, deletes the merged branch, and retargets and restacks those branches onto trunk. Then, for each of them, run `gs upstack submit --branch <name> --update-only --nav-comment=false` to update its PRs and those above it. If nothing was stacked on it, stop after the sync. Never run `gs upstack submit` or `gs stack submit` from `$base`: it would push every stack. Otherwise:

```sh
git checkout "$base"
git pull --ff-only
```

Delete the local PR branch if `gh pr checkout` created it and it has no unpushed work.

## Report

PR, gate commands run, land commit SHA, merge commit SHA, final state. Offer (don't post unasked) a PR comment summarising the gate and SHAs.
