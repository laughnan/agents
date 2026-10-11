---
name: principle-subtract-before-you-add
description: "Apply when planning an addition, refactor, or rewrite, or when tempted to add a layer, validator, option, or guard. Remove dead code, redundant checks, and stub references first, then build on the simpler base."
license: MIT
metadata:
  source: https://github.com/cursor/plugins/tree/main/pstack/skills/principle-subtract-before-you-add
---

# Subtract Before You Add

When evolving a system, remove complexity first, then build. Default to subtraction.

Make simplification a continual investment. Leave the design slightly simpler and more capable behind the same or smaller surface than you found it.

- Sequence removal before construction
- Cut before you polish (get to the minimum before investing in quality)
- Design for observed usage, not speculative edge cases
- No speculative validators, parsers, or guards beyond what the spec demands
- Simplify prompts (remove redundant instructions, excessive templates)
- When a reference has no novel content, delete it rather than leaving a stub
