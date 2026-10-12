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

Either way, drop the jargon and speak coherently, like one human talking to
another. Say it more simply and more briefly than you think you need to. If a
technical term is unavoidable, say what it means in everyday words the first
time.

## `/bro` with nothing after it

Restate your last message: same content, same conclusions, plainer and shorter
words. Don't add definitions, examples, or new material it didn't have.

## `/bro <topic>`

Explain that topic without assuming any jargon. If it's about the current work
(this repo, this chat, a change you made), ground it in the code and the
conversation rather than a generic explanation.

- Start with what it is in one plain sentence.
- Give one concrete example or everyday comparison when it makes the idea land.
- Give the smallest complete answer, then stop. The user will ask for more.
