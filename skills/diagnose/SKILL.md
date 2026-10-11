---
name: diagnose
description: "Disciplined diagnosis loop for hard bugs and performance regressions: build a red-capable feedback loop, reproduce, minimise, rank hypotheses, instrument, fix with a regression test. Use when the user says \"diagnose\", \"debug this\", or reports something broken, throwing, failing, flaky, or slow."
license: MIT
metadata:
  source: https://github.com/mattpocock/skills/tree/main/skills/engineering/diagnosing-bugs
---

# Diagnose

A discipline for hard bugs. Skip a phase only with an explicit reason.

Read `GLOSSARY.md` (if present) for the domain model and any ADRs in the area you touch.

## Redact

Write `<REDACTED>` in place of every secret in commands, outputs and artifacts you show. Build loops against env vars so credentials stay in the environment. Captured artifacts carry auth headers: quote only the lines that carry the signal. If redacted output is not enough, say so and ask the user.

## Phase 1: Build a feedback loop

**This is the skill.** With a tight pass/fail signal that goes red on _this_ bug, you will find the cause; bisection, hypotheses and instrumentation just consume it. Without one, staring at code will not save you. Spend disproportionate effort here. Be creative; refuse to give up.

Ways to build one, roughly in order:

1. Failing test at whatever seam reaches the bug (unit, integration, e2e).
2. Curl / HTTP script against a running dev server.
3. CLI invocation on a fixture input, diffing stdout against a known-good snapshot.
4. Headless browser script (Playwright / Puppeteer) asserting on DOM, console, network.
5. Replay a captured trace: save a real request / payload / event log, replay it through the code path in isolation.
6. Throwaway harness: minimal subset of the system (one service, mocked deps) hitting the bug path with one call.
7. Property / fuzz loop: for "sometimes wrong output", run 1000 random inputs.
8. Bisection harness: if the bug appeared between two known states, automate "boot at X, check" so `git bisect run` can drive it.
9. Differential loop: same input through old vs new version (or two configs), diff outputs.
10. Human-in-the-loop script, last resort: if a human must click, drive them with a structured script ([references/hitl-loop.md](references/hitl-loop.md)) so the loop stays structured and their answers feed back to you.

### Tighten it

Treat the loop as a product:

- Faster? Cache setup, skip unrelated init, narrow scope.
- Sharper? Assert on the specific symptom, not "didn't crash".
- More deterministic? Pin time, seed RNG, isolate filesystem, freeze network.

A 30-second flaky loop is barely better than none; a 2-second deterministic one is a superpower.

**Non-deterministic bugs:** the goal is a higher reproduction rate, not a clean repro. Loop the trigger 100x, parallelise, add stress, narrow timing windows, inject sleeps. 50% flake is debuggable; 1% is not.

**Cannot build a loop?** Stop and say so. List what you tried. Ask for (a) access to an environment that reproduces it, (b) a redacted artifact (HAR, log dump, core dump, timestamped recording), or (c) permission to add temporary production instrumentation. Do not hypothesise without a loop.

### Done when

You can name **one command** you have **already run** (show it and its redacted output) that is:

- [ ] **Red-capable**: drives the real bug path and asserts the user's exact symptom; can go red on this bug and green once fixed.
- [ ] **Deterministic**: same verdict every run (flaky bugs: a pinned, high repro rate).
- [ ] **Fast**: seconds, not minutes.
- [ ] **Agent-runnable**: unattended; a human only via the HITL script.

If you catch yourself reading code to build a theory before this command exists, stop. No red-capable command, no Phase 2.

## Phase 2: Reproduce and minimise

Run the loop and watch it go red. Confirm:

- [ ] It is the failure the **user** described, not a nearby one. Wrong bug, wrong fix.
- [ ] It reproduces across runs (or at a debuggable rate).
- [ ] You captured the exact symptom (message, wrong output, timing) to verify the fix later.

Then shrink to the smallest scenario that still goes red. Cut inputs, callers, config, data and steps one at a time, re-running after each cut. Done when every remaining element is load-bearing: removing any one turns it green. The minimal repro shrinks the hypothesis space and becomes the regression test.

## Phase 3: Hypothesise

Generate **3-5 ranked hypotheses** before testing any. One hypothesis anchors on the first plausible idea.

Each must be falsifiable: "If X is the cause, then changing Y makes the bug disappear / changing Z makes it worse." No prediction means it is a vibe: sharpen or discard.

Show the ranked list to the user before testing; they often re-rank instantly or have already ruled some out. Don't block on it if they are away.

## Phase 4: Instrument

Each probe maps to a specific prediction. Change one variable at a time.

1. Debugger / REPL if available. One breakpoint beats ten logs.
2. Targeted logs at the boundaries that distinguish hypotheses.
3. Never "log everything and grep".

Tag every debug log with a unique prefix, e.g. `[DEBUG-a4f2]`, so cleanup is one grep.

**Performance:** logs are usually the wrong tool. Establish a baseline measurement (timing harness, profiler, query plan), then bisect. Measure first, fix second.

## Phase 5: Fix and regression test

Write the regression test **before** the fix, but only at a **correct seam**: one where the test exercises the real bug pattern as it occurs at the call site. A too-shallow seam (single caller when the bug needs several, a unit test that cannot replicate the triggering chain) gives false confidence. If no correct seam exists, that is a finding: the architecture prevents locking the bug down. Report it.

With a correct seam:

1. Turn the minimised repro into a failing test there.
2. Watch it fail. If you forced red by mutating code or a fixture, `diff` against a pristine copy to prove the mutation landed.
3. Apply the fix.
4. Watch it pass.
5. Re-run the Phase 1 loop against the original, un-minimised scenario.

## Phase 6: Cleanup

Before declaring done:

- [ ] Original repro no longer reproduces (re-run the Phase 1 loop).
- [ ] Regression test passes, or the missing seam is documented.
- [ ] All `[DEBUG-...]` instrumentation removed (grep the prefix).
- [ ] Throwaway prototypes deleted or moved to a clearly marked debug location.
- [ ] The confirmed hypothesis is stated in the commit / PR message.
