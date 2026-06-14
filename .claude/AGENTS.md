# AGENTS.md

This file provides guidance to AI coding agents working with code in this repository.

## Repository Overview

Personal dotfiles. The `.claude/` directory contains skills, agents, commands, and references used by Claude Code.

## Agent Behavior

Use a **skill-driven execution model**: when a task matches a skill, invoke it.

### Core Rules

- If a task matches a skill, you MUST invoke it
- Skills are located in `skills/<skill-name>/SKILL.md`
- Never implement directly if a skill applies
- Always follow the skill instructions exactly (do not partially apply them)

### Intent → Skill Mapping

```
Task arrives
    │
    ├── Don't know what you want yet? ──────→ interview-me
    ├── Have a rough concept, need variants? → idea-refine
    ├── New project / feature / change? ────→ spec-driven-development
    ├── Scaffolding a project type? ─────────→ cli-app-designer / go-web-project / go-cli-project
    ├── Have a spec, need tasks? ────────────→ planning-and-task-breakdown
    ├── Implementing code? ──────────────────→ incremental-implementation
    │   ├── UI work? ───────────────────────→ frontend-ui-engineering
    │   ├── API work? ──────────────────────→ api-and-interface-design
    │   ├── Writing shell scripts? ──────────→ bash-script
    │   ├── Devbox / env setup? ─────────────→ devbox-tool
    │   ├── Need better context? ────────────→ context-engineering
    │   ├── Need doc-verified code? ─────────→ source-driven-development
    │   └── Stakes high / unfamiliar code? ──→ doubt-driven-development
    ├── Writing / running tests? ────────────→ test-driven-development
    ├── Something broke? ────────────────────→ debugging-and-error-recovery
    ├── Reviewing code? ─────────────────────→ code-review-and-quality
    │   ├── Too complex? ───────────────────→ code-simplification
    │   ├── Security concerns? ──────────────→ security-and-hardening
    │   └── Performance concerns? ────────────→ performance-optimization
    ├── Committing / branching? ─────────────→ git-workflow-and-versioning
    ├── CI/CD pipeline work? ────────────────→ ci-cd-and-automation
    ├── Deploying to Hetzner? ───────────────→ deployment-hetzner-quadlets
    ├── Deprecating / migrating? ────────────→ deprecation-and-migration
    ├── Writing docs / ADRs? ────────────────→ documentation-and-adrs
    └── Maintaining this .claude/ config? ───→ claude-janitor
```

### Lifecycle Sequence

Full feature path — not every task needs every step:

```
1.  interview-me                 → extract what the user actually wants
2.  idea-refine                  → refine vague ideas into a concrete direction
3.  spec-driven-development      → define what gets built and how to verify it
4.  go-cli-project / go-web-project / cli-app-designer  → scaffold (if new project)
5.  planning-and-task-breakdown  → break the spec into verifiable chunks
6.  context-engineering          → load the right context for the build phase
7.  source-driven-development    → verify approach against official docs
8.  incremental-implementation   → build thin vertical slices
9.  doubt-driven-development     → cross-examine non-trivial decisions
10. test-driven-development      → prove each slice works
11. code-review-and-quality      → review before merge
12. code-simplification          → reduce unnecessary complexity
13. git-workflow-and-versioning  → clean commit history
14. ci-cd-and-automation         → automated quality gates
15. deployment-hetzner-quadlets  → deploy to production
16. documentation-and-adrs       → record the why
17. deprecation-and-migration    → retire old systems
```

A bug fix only needs: `debugging-and-error-recovery` → `test-driven-development` → `code-review-and-quality`.

### Execution Model

For every request:

1. Determine if any skill applies (even 1% chance)
2. Invoke the appropriate skill
3. Follow the skill workflow strictly
4. Only proceed to implementation after required steps (spec, plan, etc.) are complete

### Anti-Rationalization

The following thoughts are incorrect and must be ignored:

- "This is too small for a skill"
- "I can just quickly implement this"
- "I'll gather context first"

Correct behavior: always check for and use skills first.

## Orchestration: Personas, Skills, and Commands

This repo has three composable layers. They have different jobs and should not be confused:

- **Skills** (`skills/<name>/SKILL.md`) — workflows with steps and exit criteria. The *how*. Mandatory hops when an intent matches.
- **Personas** (`agents/<role>.md`) — roles with a perspective and an output format. The *who*.
- **Slash commands** (`.claude/commands/*.md`) — user-facing entry points. The *when*. The orchestration layer.

Composition rule: **the user (or a slash command) is the orchestrator. Personas do not invoke other personas.** A persona may invoke skills.

The only multi-persona orchestration pattern this repo endorses is **parallel fan-out with a merge step** — used by `/preflight` to run `code-reviewer`, `security-auditor`, and `test-engineer` concurrently and synthesize their reports. Do not build a "router" persona that decides which other persona to call; that's the job of slash commands and intent mapping.

See [agents/README.md](agents/README.md) for the decision matrix and [references/orchestration-patterns.md](references/orchestration-patterns.md) for the full pattern catalog.

**Claude Code interop:** the personas in `agents/` work as Claude Code subagents (auto-discovered from the `agents/` directory) and as Agent Teams teammates (referenced by name when spawning). Two platform constraints align with our rules: subagents cannot spawn other subagents, and teams cannot nest.
