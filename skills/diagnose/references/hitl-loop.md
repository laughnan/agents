# Human-in-the-loop reproduction script

Last-resort loop when a human must perform a step. Copy the script below to a scratch location, edit the steps, and run it. The user follows the prompts in their terminal; captured values print as `KEY=VALUE` at the end for you to parse.

`capture` echoes its value back where you can read it, so capture observations only. Leave signing in to the user as a `step`, never a `capture`.

```bash
#!/usr/bin/env bash
set -euo pipefail

step() {
  printf '\n>>> %s\n' "$1"
  read -r -p "    [Enter when done] " _
}

capture() {
  local var="$1" question="$2" answer
  printf '\n>>> %s\n' "$question"
  read -r -p "    > " answer
  printf -v "$var" '%s' "$answer"
}

# --- edit below ---------------------------------------------------------

step "Open the app at http://localhost:3000 and sign in."

capture ERRORED "Click the 'Export' button. Did it throw an error? (y/n)"

capture ERROR_MSG "Paste the error message (or 'none'):"

# --- edit above ---------------------------------------------------------

printf '\n--- Captured ---\n'
printf 'ERRORED=%s\n' "$ERRORED"
printf 'ERROR_MSG=%s\n' "$ERROR_MSG"
```
