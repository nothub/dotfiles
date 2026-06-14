# .claude

Personal Claude Code config: skills, commands, agent personas, and references.

Skills are engineering workflow processes loaded on demand. Commands are slash-command entry points. Personas (`agents/`) run as subagents via the Agent tool.

## Commands

| Command | What it does |
|---------|-------------|
| `/spec` | Write a structured specification before writing any code |
| `/plan` | Break work into small verifiable tasks with acceptance criteria |
| `/build` | Sequential chain: spec → plan → full TDD implementation, one commit per task |
| `/test` | TDD workflow: write failing tests, implement, verify |
| `/review` | Five-axis code review: correctness, readability, architecture, security, performance |
| `/code-simplify` | Simplify code for clarity without changing behavior |
| `/preflight` | Parallel fan-out: three specialist personas → go/no-go → local artifact |
| `/maintain` | Audit and maintain this `.claude/` directory |

## Orchestration commands

Two commands orchestrate multiple skills or personas. They are the only entry points for multi-step automated work.

### `/build` — sequential chain

Implements a full spec in one autonomous pass. One human checkpoint (plan approval), then runs to completion.

```
/build
  ├── Phase 1: verify spec exists, check git baseline
  ├── Phase 2: generate plan (if needed) → human approval checkpoint
  └── Phase 3: for each task → RED test → GREEN impl → regression → build → commit
```

Use when: you have a spec and want the full implementation done without stepping between tasks.

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

See [CLAUDE.md](CLAUDE.md) for the full skills table with one-liner descriptions.
