#!/usr/bin/env bash
# PreToolUse(Bash): gh commands that publish text to GitHub must carry the agent
# footer. Missing footer -> deny with instructions so Claude retries with it.
# Footer present -> force a permission prompt, so "approved by alex" is true.
# One exception skips the prompt: a body-only description edit whose body file
# carries the footer (see below).
set -euo pipefail

FOOTER="— 👶 bébé, alex's agent · approved by alex"
MARKER="bébé, alex's agent"

cmd=$(jq -r '.tool_input.command // empty')
[[ -z "$cmd" ]] && exit 0
[[ "$cmd" == *"gh "* ]] || exit 0

# `gh [-R o/r] pr|issue edit [<n>] --body-file <path>` and nothing else is allowed
# outright when the file holds the footer line. The narrow character set rules out
# chaining, substitution, redirects, quoting and comments, so the file is exactly
# what GitHub receives. Any other edit flag falls through to the prompt.
edit_re='^gh[[:space:]]+((-R|--repo)[[:space:]]+[A-Za-z0-9._/-]+[[:space:]]+)?(pr|issue)[[:space:]]+edit([[:space:]]+[A-Za-z0-9][A-Za-z0-9._/:-]*)?[[:space:]]+(--body-file|-F)[[:space:]]+([A-Za-z0-9._/~][A-Za-z0-9._/~-]*)[[:space:]]*$'
if [[ "$cmd" =~ $edit_re ]]; then
  f="${BASH_REMATCH[6]/#\~/$HOME}"
  if [[ -f "$f" ]] && grep -qxF -- "$FOOTER" "$f"; then
    jq -n '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "allow",
      permissionDecisionReason: "Body-only description edit with the agent footer."}}'
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

if [[ "$text" == *"$MARKER"* ]]; then
  jq -n '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "ask",
    permissionDecisionReason: "Posting to GitHub as alex — confirm before bébé publishes."}}'
else
  jq -n --arg f "$FOOTER" '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny",
    permissionDecisionReason: ("This posts text to GitHub on alex'\''s behalf but is missing the agent footer. Re-run with this exact line appended to the body text (or the --body-file contents), separated by a blank line:\n\n" + $f + "\n\nShell variables are not expanded, so write the footer literally in the body or pass a literal --body-file path.")}}'
fi
