---
name: tdd
description: "Test-driven development in vertical red-green slices at agreed seams, with rules for what makes a test worth keeping and when to mock. Use when building a feature or fixing a bug test-first, or when the user mentions TDD, \"red-green\", \"test first\", or integration tests."
license: MIT
metadata:
  source: https://github.com/mattpocock/skills/tree/main/skills/engineering/tdd
---

# TDD

TDD is the red -> green loop. This skill is what makes that loop produce tests worth keeping. Consult every section before and during the loop, not after.

Read `GLOSSARY.md` (if present) so test names and interface vocabulary match the domain language, and respect ADRs in the area you touch.

## What a good test is

Tests verify behavior through public interfaces, not implementation details. The code can change entirely; the tests shouldn't. A good test reads like a specification ("user can checkout with valid cart") and survives refactors because it doesn't care about internal structure.

Examples: [references/tests.md](references/tests.md). Mocking rules: [references/mocking.md](references/mocking.md).

## Seams: where tests go

A **seam** is the public boundary you test at: where you observe behavior without reaching inside. Tests live at seams, never against internals.

**Test only at pre-agreed seams.** Before writing any test, list the seams under test and confirm them with the user. You can't test everything; agreeing seams up front puts effort on critical paths and complex logic instead of every edge case.

Ask: "What's the public interface, and which seams should we test?" Give each proposed seam one line on what it catches and what it misses.

If the interface shape itself is in question, prefer a deep module (small interface, lots of behavior behind it) and the highest seam that still observes the behavior. Fewer seams is better.

## Anti-patterns

- **Implementation-coupled**: mocks internal collaborators, tests private methods, or verifies through a side channel (querying the DB instead of the interface). Tell: it breaks on a refactor that didn't change behavior.
- **Tautological**: the expected value is computed the way the code computes it (`expect(add(a, b)).toBe(a + b)`), so it passes by construction. Expected values come from an independent source: a known literal, a worked example, the spec.
- **Horizontal slicing**: all tests first, then all implementation. Bulk tests verify imagined behavior, test shape instead of user-facing behavior, and lock in structure before you understand the implementation. Work in **vertical slices**: one test, one implementation, repeat. Each test is a tracer bullet that responds to what the last cycle taught you.

## Rules of the loop

- **Red before green.** Write the failing test, watch it fail for the right reason, then write only enough code to pass. No speculative features.
- **One slice at a time.** One seam, one test, one minimal implementation per cycle.
- **Refactoring is not part of the loop.** Do it as a separate pass once slices are green (for an independent review of the result, run `autoreview`).
