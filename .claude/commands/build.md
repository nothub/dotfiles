---
description: Build from spec to working artifact — plan if needed, get one approval, then implement every task with TDD, one commit per task.
---

`/build` is a **sequential chain**. It ensures a spec and a plan exist, gets one human checkpoint, then implements every task autonomously — each with a failing test, a passing implementation, and its own commit.

## Phase 1 — Prerequisites

1. **Resolve qualifier.** Use `$ARGUMENTS` as the qualifier slug (e.g. `/build user-auth`). If no argument is given, run `ls docs/ai/*.md`: if exactly one file, extract the qualifier from its name (strip the date prefix); if multiple, ask; if none, stop and tell the user to run `/spec` first.
2. **Require a spec.** Look only at the `## Spec` section in `docs/ai/{date}-{qualifier}.md`. A README or arbitrary doc does not count.
3. **Establish a clean baseline.** Run `git status --porcelain`. If there are uncommitted changes outside planning artifacts (`docs/ai/`), stop and ask the user to commit, stash, or confirm how to handle them. Per-task commits must not absorb unrelated local work.

## Phase 2 — Plan

If `docs/ai/{date}-{qualifier}.md` has no `## Plan` section yet, invoke `planning-and-task-breakdown` to generate `## Plan` and `## Tasks` sections in it.

Present the full plan and wait for an unambiguous affirmative ("approve", "go", "yes"). Treat hedged responses ("looks reasonable", "I guess") as **not** approved. This is the only human gate.

If the plan was just generated, commit it as a single preparatory commit now so it doesn't bleed into the first task's commit.

## Phase 3 — Execute

For each task in dependency order:

1. Write a failing test for the expected behavior (RED)
2. Implement the minimum code to make it pass (GREEN)
3. Run the full test suite for regressions
4. Run the build to verify compilation
5. Commit with a descriptive message — stage only files that task touched plus the `docs/ai/{date}-{qualifier}.md` task-status update, never `git add -A`
6. Check off the task in the `## Tasks` section and bump `updated:`

Stop and ask (do not push through) when:
- A test can't be made to pass or the build breaks without an obvious fix → follow `debugging-and-error-recovery`
- The spec is ambiguous or a task needs a decision the spec doesn't cover
- A task is high-risk or irreversible: auth/permission changes, destructive data migrations, payments, deletions, deploys, secrets, or anything not undoable with `git revert` → follow `doubt-driven-development` and get explicit sign-off

Re-invoke `/build` after resolving a blocker — it resumes from the next pending task.

## Completion

Summarize: tasks completed, tests added, commits made, anything skipped or flagged.

## Rules

1. One commit per task — every point in history is a clean rollback target
2. Never `git add -A` — stage only what the task touched
3. Autonomous between tasks after the plan checkpoint — no stepping between tasks
4. Stop immediately on blockers; do not push through
