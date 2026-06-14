# ~/.claude

Personal AI coding-agent config for Claude Code: skills, commands, agent personas, and references.

- [Skills](./skills) are engineering workflow processes loaded on demand.  
- [Commands](./commands) are slash-command entry points.  
- [Personas](./agents) run as subagents via the Agent tool.

## Commands

| Command | What it does |
|---------|-------------|
| `/spec` | Write a structured specification before writing any code |
| `/plan` | Sequential chain: planning → doubt-driven stress-test → human approval |
| `/build` | Sequential chain: spec → plan → full TDD implementation, one commit per task |
| `/test` | TDD workflow: write failing tests, implement, verify |
| `/review` | Five-axis code review: correctness, readability, architecture, security, performance |
| `/code-simplify` | Sequential chain: simplify → review loop (max 3 cycles) until clean |
| `/preflight` | Parallel fan-out: three specialist personas → go/no-go → local artifact |
| `/claude-janitor` | Audit and maintain this `.claude/` directory |

## Orchestration commands

These commands orchestrate multiple skills or personas. They are the only entry points for multi-step automated work.

### `/plan` — sequential chain with adversarial stress-test

Generates a task breakdown, then applies `doubt-driven-development` to find gaps before the user ever sees it.

```
/plan
  ├── Phase 1: planning-and-task-breakdown → tasks/plan.md
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
                  ↓
        go/no-go decision → artifact build on GO
```

Use when: a change is ready to ship and needs a quality gate before building a release artifact.

## Skills

See [AGENTS.md](AGENTS.md) for the full skills table with one-liner descriptions.
