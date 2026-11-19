#!/usr/bin/env bash
# PreToolUse(Bash): gh commands that publish text to GitHub go out as alex, so
# they must not credit an agent (persona, "Generated with", agent co-author or
# session link). Credit present -> deny with instructions to remove it.
# Otherwise -> force a permission prompt, so alex approves every post.
# One exception skips the prompt: a body-only description edit whose body file
# has no credit (see below).
set -euo pipefail

# Agent credit, matched case-insensitively (grep -Ei). review-loop's
# reply-resolve reads this line too.
CREDIT_RE='bébé|generated (with|by) \[?(claude|codex|cursor)|co-authored-by:.*(claude|codex|cursor|anthropic|openai)|claude\.ai/code/session'

cmd=$(jq -r '.tool_input.command // empty')
[[ -z "$cmd" ]] && exit 0

deny_credit() {
  jq -n '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny",
    permissionDecisionReason: "This posts to GitHub as alex but credits an agent. Remove every agent credit from the body text (or the --body-file contents) and re-run: no agent name or footer, no \"Generated with\" line, no session link, and no agent co-author line."}}'
}
ask() {
  jq -n --arg r "$1" '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "ask",
    permissionDecisionReason: $r}}'
}

# review-loop's reply-resolve posts thread replies with gh inside a script, so
# gate it like a gh write: the replies file must be a non-empty array, no body
# may credit an agent, and then it prompts.
rr_re='reply-resolve[[:space:]]+[0-9]+[[:space:]]+([^[:space:];&|]+)'
if [[ "$cmd" =~ $rr_re ]]; then
  f="${BASH_REMATCH[1]/#\~/$HOME}"
  if ! [[ -f "$f" ]] || ! jq -e 'type == "array" and length > 0' "$f" >/dev/null 2>&1; then
    jq -n '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny",
      permissionDecisionReason: "reply-resolve posts to GitHub on alex'\''s behalf, but its replies file is missing, unreadable, or not a non-empty JSON array."}}'
  elif jq -r '.[].body // ""' "$f" | grep -Eiq -- "$CREDIT_RE"; then
    deny_credit
  else
    ask "Posting review replies to GitHub as alex. Confirm before they are published."
  fi
  exit 0
fi

[[ "$cmd" == *"gh "* ]] || exit 0

# `gh [-R o/r] pr|issue edit [<n>] --body-file <path>` and nothing else is allowed
# outright when the file has no agent credit. The narrow character set rules out
# chaining, substitution, redirects, quoting and comments, so the file is exactly
# what GitHub receives. Any other edit flag falls through to the prompt.
edit_re='^gh[[:space:]]+((-R|--repo)[[:space:]]+[A-Za-z0-9._/-]+[[:space:]]+)?(pr|issue)[[:space:]]+edit([[:space:]]+[A-Za-z0-9][A-Za-z0-9._/:-]*)?[[:space:]]+(--body-file|-F)[[:space:]]+([A-Za-z0-9._/~][A-Za-z0-9._/~-]*)[[:space:]]*$'
if [[ "$cmd" =~ $edit_re ]]; then
  f="${BASH_REMATCH[6]/#\~/$HOME}"
  if [[ -f "$f" ]]; then
    if grep -Eiq -- "$CREDIT_RE" "$f"; then deny_credit; exit 0; fi
    jq -n '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "allow",
      permissionDecisionReason: "Body-only description edit with no agent credit."}}'
    exit 0
  fi
fi

# Drop global repo flags (-R x, -Rx, --repo x, --repo=x) so `gh -R o/r pr comment`
# matches the same patterns as `gh pr comment`.
match=$(sed -E 's/(-R|--repo)(=|[[:space:]]+)?[^[:space:]]+//g' <<<"$cmd")

posts=0
# gh pr/issue comment|create, and gh pr review / edit when given a body
if grep -Eq 'gh[[:space:]]+(pr|issue)[[:space:]]+(comment|create)\b' <<<"$match"; then posts=1; fi
if grep -Eq 'gh[[:space:]]+(pr|issue)[[:space:]]+(review|edit)\b' <<<"$match" \
  && grep -Eq '(^|[[:space:]])(-b|--body|-F|--body-file)([[:space:]=]|$)' <<<"$match"; then posts=1; fi
# gh api writes to comments/reviews/issues/pulls with a body field or input file
if grep -Eq 'gh[[:space:]]+api\b' <<<"$match" \
  && grep -Eq '/(comments|reviews|issues|pulls)\b' <<<"$match" \
  && grep -Eq '(-f|-F|--field|--raw-field)[[:space:]]+body=|--input([[:space:]=])' <<<"$match"; then posts=1; fi
[[ $posts -eq 1 ]] || exit 0

# Collect text to check: the command itself plus any body/input file it references.
text="$cmd"
while read -r f; do
  f="${f/#\~/$HOME}"
  [[ -f "$f" ]] && text+=$'\n'"$(cat -- "$f")"
done < <(grep -Eo '(--body-file|--input|-F)[[:space:]=]+[^[:space:]]+|body=@[^[:space:]]+' <<<"$cmd" \
  | sed -E 's/^(--body-file|--input|-F)[[:space:]=]+//; s/^body=@//; s/^["'\'']//; s/["'\'']$//' \
  | grep -v '^-$' || true)

if grep -Eiq -- "$CREDIT_RE" <<<"$text"; then
  deny_credit
else
  ask "Posting to GitHub as alex. Confirm before it is published."
fi
