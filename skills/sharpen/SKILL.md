---
name: sharpen
description: "Make a task deeper, not bigger: name what a top professional would do, start from, use, and check against, then rewrite the prompt to ask for that. Use for /sharpen, 'sharpen this', or 'make this prompt deeper'."
disable-model-invocation: true
license: MIT
metadata:
  source: https://github.com/cursor/plugins/tree/main/pstack/skills/sharpen
---

# Sharpen

The user wants a deeper version of their task, not a bigger one. Before rewriting it, do four things:

1. Say what a top professional in this field would do here that the user isn't asking for.
2. Name the rawest material they would start from, instead of what has already been digested.
3. Name the specific methods and tools they would use.
4. Say what, other than you or the user, would show the result is right.

Then rewrite the prompt to ask for exactly that. Return the rewrite; don't start the work.

Leave choices that are the user's to make open instead of deciding them.
