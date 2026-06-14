# .claude

Personal Claude Code config: skills, commands, agent personas, and references.

Skills are engineering workflow processes loaded on demand. Commands are slash-command entry points. Personas (`agents/`) run as subagents via the Agent tool.

## Commands

| Command | What it does |
|---------|-------------|
| `/spec` | Write a structured specification before writing any code |
| `/plan` | Break work into small verifiable tasks with acceptance criteria |
| `/build` | Implement the next pending task — build, test, verify, commit |
| `/build auto` | Run the full plan in one approved autonomous pass |
| `/test` | TDD workflow: write failing tests, implement, verify |
| `/review` | Five-axis code review: correctness, readability, architecture, security, performance |
| `/code-simplify` | Simplify code for clarity without changing behavior |
| `/preflight` | Pre-release checklist — parallel fan-out → go/no-go → local artifact |
| `/maintain` | Audit and maintain this `.claude/` directory |

## Command chains

### User-driven lifecycle

The user drives the sequence. Each skill suggests the next step — no auto-chaining.

```
/spec → /plan → /build → /test → /review → /preflight
```

### /preflight (parallel fan-out)

```
/preflight → code-reviewer   ─┐
           → security-auditor ─┼─ parallel → merge → go/no-go → artifact build
           → test-engineer   ──┘
```

### Direct invocations

All other commands invoke a single skill with no fan-out:

| Command | Skill |
|---------|-------|
| `/spec` | spec-driven-development |
| `/plan` | planning-and-task-breakdown |
| `/build` | incremental-implementation + test-driven-development |
| `/test` | test-driven-development |
| `/review` | code-review-and-quality |
| `/code-simplify` | code-simplification |
| `/maintain` | claude-dir-maintenance |

## Skills

See [CLAUDE.md](CLAUDE.md) for the full skills table with one-liner descriptions.
