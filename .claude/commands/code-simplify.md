---
description: Simplify code for clarity — reduce complexity, then verify with review. Loops up to 3 cycles until clean.
---

`/code-simplify` is a **sequential chain with a verification loop**. It simplifies the target code, then reviews the result. If the review finds issues, it fixes them and reviews again — at most 3 review cycles.

**Success criteria** (Goal-Driven Execution — CLAUDE.md):
- All tests pass
- Build is clean
- `code-review-and-quality` finds no Critical or Important findings

## Phase 1 — Simplify

Invoke the `code-simplification` skill on the target scope. Default scope: recently changed code. Explicit scope: `$ARGUMENTS` if provided.

## Phase 2 — Verify (max 3 cycles)

1. Run `code-review-and-quality` on the simplified code
2. No Critical or Important findings → success, report clean result and stop
3. Findings exist → fix them, increment cycle counter, return to step 1
4. Cycle counter hits 3 with unresolved findings → cancel and report:
   - What was simplified
   - Which findings remain unresolved
   - Whether the blocker is a real bug or confusion about the code's intent

## Rules

1. Simplify once in Phase 1 — Phase 2 fixes only what the review surfaces, it does not re-simplify
2. Hard loop limit: 3 review cycles — do not attempt a fourth
3. On cancel: distinguish unsolved bugs from intent confusion in the report
