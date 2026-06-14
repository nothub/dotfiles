---
description: Break work into small verifiable tasks, stress-test the plan with doubt-driven-development, then present for approval.
---

`/plan` is a **sequential chain**. It generates a task breakdown from the spec, stress-tests it adversarially, and only presents the plan for human approval once it passes.

**Success criteria** (Goal-Driven Execution — CLAUDE.md):
- Every task has acceptance criteria and a verification step
- No task touches more than ~5 files
- Dependencies are correctly ordered with no gaps between phases
- `doubt-driven-development` finds no Valid+Actionable findings

## Phase 1 — Plan

Invoke `planning-and-task-breakdown`. Read the spec at a known path (`SPEC.md`, `docs/SPEC.md`, or under `spec/`). If none exists, stop and tell the user to run `/spec` first.

Save the plan to `tasks/plan.md` and task list to `tasks/todo.md`.

## Phase 2 — Stress-test

Apply `doubt-driven-development` to the plan as the artifact.

CONTRACT: "Each task is completable in one focused session, has explicit acceptance criteria, has a verification step, touches no more than ~5 files, dependency ordering is correct, and no phase leaves the system in a broken state."

The skill runs its own bounded loop (max 3 cycles per its Step 5 stop condition). If it escalates after 3 cycles with unresolved findings, the plan is not ready — report what remains unresolved and stop.

## Phase 3 — Approval

Once `doubt-driven-development` passes (no actionable findings, or only documented trade-offs), present the final plan for human approval. Wait for an explicit affirmative before handing off to `/build`.

## Rules

1. Do not present the plan for approval until Phase 2 passes
2. `doubt-driven-development`'s 3-cycle hard limit is the bound — do not override it
3. On cancel: report what doubt found unresolved; the user decides whether to revise the spec or accept the risk
