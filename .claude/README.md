# ~/.claude

Personal AI coding-agent config for Claude Code: skills, commands, agent personas, and references.

- [Skills](./skills) are engineering workflow processes loaded on demand.  
- [Commands](./commands) are slash-command entry points.  
- [Personas](./agents) run as subagents via the Agent tool.

## Commands

| Command           | What it does                                                                              | Call flow                                                                |
|-------------------|-------------------------------------------------------------------------------------------|--------------------------------------------------------------------------|
| `/spec`           | Write a structured specification before writing any code                                  | `spec-driven-development`                                                |
| `/plan`           | Turn a spec into an adversarially stress-tested task breakdown, ready for approval        | `planning-and-task-breakdown` → `doubt-driven-development` → approval    |
| `/build`          | Requires a spec; generates a plan if none exists, then implements every task with TDD     | [`planning-and-task-breakdown` →] approval → RED→GREEN→commit (×n tasks) |
| `/test`           | Write failing tests first, implement to pass, verify no regressions                       | `test-driven-development`                                                |
| `/review`         | Five-axis code review: correctness, readability, architecture, security, performance      | `code-review-and-quality`                                                |
| `/code-simplify`  | Reduce complexity, then verify clean — no Critical or Important findings remain           | `code-simplification` → `code-review-and-quality` (×3)                   |
| `/preflight`      | Pre-release quality gate: review, security, and coverage → go/no-go; build artifact on GO | `code-reviewer` ∥ `security-auditor` ∥ `test-engineer` → merge           |
| `/claude-janitor` | Audit and maintain this `.claude/` directory                                              | `claude-janitor`                                                         |

## Orchestration commands

These commands orchestrate multiple skills or personas. They are the only entry points for multi-step automated work.

### `/plan` — sequential chain with adversarial stress-test

Generates a task breakdown, then applies `doubt-driven-development` to find gaps before the user ever sees it.

```
/plan
  ├── Phase 1: planning-and-task-breakdown → tasks/plan.md + tasks/todo.md
  ├── Phase 2: doubt-driven-development (max 3 cycles) → revise on findings
  └── Phase 3: present clean plan → human approval checkpoint
```

Use when: you have a spec and want a plan that has been adversarially reviewed before you approve it.

### `/build` — sequential chain

Implements a full spec in one autonomous pass. One human checkpoint (plan approval), then runs to completion.

```
/build
  ├── Phase 1: verify spec exists, check git baseline
  ├── Phase 2: generate plan (if needed) → human approval checkpoint
  └── Phase 3: for each task → RED test → GREEN impl → regression → build → commit
```

Use when: you have a spec and want the full implementation done without stepping between tasks.

### `/code-simplify` — sequential chain with verification loop

Simplifies code, then reviews the result. Fixes issues and re-reviews until clean or the loop limit is hit.

```
/code-simplify
  ├── Phase 1: code-simplification (once)
  └── Phase 2: code-review-and-quality → fix → review → (max 3 cycles)
                └── clean: done  |  3 cycles unresolved: cancel + report
```

Use when: code works but has accumulated complexity — you want it simplified and verified clean in one pass.

### `/preflight` — parallel fan-out

Pre-release quality gate. Three specialist personas run concurrently, then results are merged into a go/no-go decision.

```
/preflight
  ├── (parallel) code-reviewer    → five-axis review report
  ├── (parallel) security-auditor → vulnerability audit report
  └── (parallel) test-engineer    → coverage analysis report
                  ↓
        merge (main agent)
          ├── aggregate persona reports
          ├── CLI usability check (direct)
          └── documentation check (direct)
                  ↓
        go/no-go decision → artifact build on GO
```

Use when: a change is ready to ship and needs a quality gate before building a release artifact.

## Skills

See [AGENTS.md](AGENTS.md) for the full skills table with one-liner descriptions.
