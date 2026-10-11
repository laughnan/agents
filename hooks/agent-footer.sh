#!/usr/bin/env bash
# PreToolUse(Bash): gh commands that publish text to GitHub must carry the agent
# footer. Missing footer -> deny with instructions so Claude retries with it.
# Footer present -> force a permission prompt, so "approved by alex" is true.
set -euo pipefail

FOOTER="— 👶 bébé, alex's agent · approved by alex"
MARKER="bébé, alex's agent"

cmd=$(jq -r '.tool_input.command // empty')
[[ -z "$cmd" ]] && exit 0
[[ "$cmd" == *"gh "* ]] || exit 0

posts=0
# gh pr/issue comment|create, and gh pr review / edit when given a body
if grep -Eq 'gh[[:space:]]+(pr|issue)[[:space:]]+(comment|create)\b' <<<"$cmd"; then posts=1; fi
if grep -Eq 'gh[[:space:]]+(pr|issue)[[:space:]]+(review|edit)\b' <<<"$cmd" \
  && grep -Eq '(^|[[:space:]])(-b|--body|-F|--body-file)([[:space:]=]|$)' <<<"$cmd"; then posts=1; fi
# gh api writes to comments/reviews/issues/pulls with a body field or input file
if grep -Eq 'gh[[:space:]]+api\b' <<<"$cmd" \
  && grep -Eq '/(comments|reviews|issues|pulls)\b' <<<"$cmd" \
  && grep -Eq '(-f|-F|--field|--raw-field)[[:space:]]+body=|--input([[:space:]=])' <<<"$cmd"; then posts=1; fi
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
    permissionDecisionReason: ("This posts text to GitHub on alex'\''s behalf but is missing the agent footer. Re-run with this exact line appended to the body, separated by a blank line:\n\n" + $f)}}'
fi
