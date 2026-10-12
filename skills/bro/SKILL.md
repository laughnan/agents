---
name: bro
description: "ELI5 (explain like I'm five): restate the last message in plain human language with no jargon, or explain a named topic from scratch the same way. Use for /bro, 'eli5', 'explain like I'm five', 'say that again simpler'."
disable-model-invocation: true
license: MIT
metadata:
  source: https://github.com/cursor/plugins/tree/main/pstack/skills/bro
---

# Bro

This is the user's ELI5 skill. If they ask for "eli5", this is the one.

- `/bro` with nothing after it: restate your last message.
- `/bro <topic>`: explain that topic from scratch.

Either way, drop the jargon and speak coherently, like one human talking to
another. Say it more simply and more briefly than you think you need to.

- Start with what it is in one plain sentence. If a technical term is
  unavoidable, say what it means in everyday words the first time.
- Give one concrete example or everyday comparison when it makes the idea land.
- Give the smallest complete answer, then stop. The user will ask for more.
