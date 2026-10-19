#!/usr/bin/env bash
# PreToolUse(Edit|Write|MultiEdit|Bash): block direct writes to files that
# ~/agents/scripts/install generates, and point the agent at the source file.
set -euo pipefail

source "$(dirname "$0")/../scripts/lib.sh"

input=$(cat)
tool=$(jq -r '.tool_name // empty' <<<"$input")

generated=(
  "$HOME/.claude/settings.json"
  "$HOME/.claude/CLAUDE.md"
  "$HOME/.codex/AGENTS.md"
)
# Protect only installed aliases owned by this checkout. Unmanaged personal
# agents remain editable; canonical agents/*.md in the repo remains editable.
for link in "$HOME/.claude/agents"/*.md; do
  [[ -L "$link" ]] || continue
  if owned_agent_target "$(readlink "$link")"; then
    generated+=("$link")
  fi
done

deny() {
  jq -n --arg target "$1" '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny",
    permissionDecisionReason: ($target + " is managed by ~/agents/scripts/install. Edit the source instead:\n- shared Claude settings: ~/agents/config/claude/settings.json\n- this laptop only: ~/agents/local/claude.settings.json\n- global rules: ~/agents/AGENTS.md (laptop only: ~/agents/local/AGENTS.md)\n- reusable roles: ~/agents/agents/<name>.md\nThen run ~/agents/scripts/install. See the agent-config skill.")}}'
  exit 0
}

case "$tool" in
  Edit|Write|MultiEdit)
    path=$(jq -r '.tool_input.file_path // empty' <<<"$input")
    path="${path/#\~/$HOME}"
    for g in "${generated[@]}"; do
      [[ "$path" == "$g" ]] && deny "$g"
    done
    ;;
  Bash)
    cmd=$(jq -r '.tool_input.command // empty' <<<"$input")
    # Drop harmless redirections so read-only commands don't look like writes.
    scrubbed=$(sed -E 's/[0-9]?>&[0-9]//g; s#[0-9]?>[[:space:]]*/dev/null##g' <<<"$cmd")
    grep -Eq '(>|\btee\b|sed[[:space:]]+-i|perl[[:space:]]+-[a-z]*i|\bmv\b|\bcp\b|\bln\b|\brm\b|\btruncate\b)' <<<"$scrubbed" || exit 0
    for g in "${generated[@]}"; do
      rel="${g#"$HOME"/}"
      for form in "$g" "~/$rel" "\$HOME/$rel"; do
        # Match the exact path only, so settings.json.bak-agents-* stays writable.
        escaped=$(sed 's/[][\.*^$()+?{}|]/\\&/g' <<<"$form")
        grep -Eq "${escaped}([^A-Za-z0-9._-]|\$)" <<<"$scrubbed" && deny "$g"
      done
    done
    ;;
esac
exit 0
