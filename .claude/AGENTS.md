# Global Agent Instructions

This file provides global guidance to AI agents.

## Repository Overview

Personal dotfiles. The `.claude/` directory contains skills, agents, commands, and references usable by AI agents.

## General Behavior

### 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:

- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines, and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

Prioritize:

- Readability
- Correctness
- Maintainability
- Idiomatic language usage

### 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.

When your changes create orphans:

- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should be traced directly to the user's request.

### 4. Prefer Standard Library and Minimal Dependencies

**Reach for the stdlib first. Every dependency is a liability.**

Before adding a third-party library:

- Can the stdlib do it without a bunch of added complexity? Use it.
- Is the library small, focused, and actively maintained? Maybe.
- Is it a framework, a meta-library, or does it pull in a tree of transitive deps?
  Only use if stdlib or small libraries are not enough and require a lot of additional complexity.

This applies to stack choices too: plain JS over React, Go `net/http` over a web framework, Raylib over a game engine,
SQLite over Postgres unless scale demands otherwise.

When a dependency is justified, prefer libraries that do one thing well over ones that try to do everything.

### 5. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:

- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## Skill-Driven Execution

Use a **skill-driven execution model**: when a task matches a skill, invoke it.

### Core Rules

- If a task matches a skill, you MUST invoke it
- Skills are located in `skills/<skill-name>/SKILL.md`
- Never implement directly if a skill applies
- Always follow the skill instructions exactly (do not partially apply them)

### Skills

| Phase    | Skill                        | Summary                                                                                     |
|----------|------------------------------|---------------------------------------------------------------------------------------------|
| Context  | context-engineering          | Right context at the right time; recover when output quality drifts                         |
| Define   | interview-me                 | Surface what the user actually wants before any plan, spec, or code exists                  |
| Define   | idea-refine                  | Refine ideas through structured divergent and convergent thinking                           |
| Define   | spec-driven-development      | Requirements and acceptance criteria before code                                            |
| Scaffold | cli-app-designer             | Design CLI commands, flags, exit codes, and help output                                     |
| Scaffold | go-web-project               | Scaffold Go web services: net/http, html/template, XDG paths, Dockerfile                    |
| Scaffold | go-cli-project               | Scaffold Go CLI binaries: USAGE.txt, CI workflows                                           |
| Scaffold | devbox-tool                  | Isolated, reproducible Nix-based dev environments via devbox.json                           |
| Scaffold | minecraft-development        | Paper plugins, Fabric mods, and NeoForge mods — scaffolding, Gradle, and MC-version pinning |
| Plan     | planning-and-task-breakdown  | Decompose into small, verifiable tasks                                                      |
| Build    | incremental-implementation   | Thin vertical slices, test each before expanding                                            |
| Build    | bash-script                  | Safe, pipe-friendly shell scripts with shellcheck and shfmt                                 |
| Build    | source-driven-development    | Verify against official docs before implementing                                            |
| Build    | doubt-driven-development     | Adversarial fresh-context review of every non-trivial decision                              |
| Build    | frontend-ui-engineering      | Semantic HTML, plain CSS, vanilla JS — no framework, no build step                          |
| Build    | api-and-interface-design     | Stable interfaces with clear contracts                                                      |
| Verify   | test-driven-development      | Failing test first, then make it pass                                                       |
| Verify   | debugging-and-error-recovery | Reproduce → localize → fix → guard                                                          |
| Review   | code-review-and-quality      | Five-axis review with quality gates                                                         |
| Review   | code-simplification          | Preserve behavior while reducing unnecessary complexity                                     |
| Review   | security-and-hardening       | OWASP prevention, input validation, least privilege                                         |
| Review   | performance-optimization     | Measure first, optimize only what matters                                                   |
| Ship     | git-workflow-and-versioning  | Atomic commits, clean history                                                               |
| Ship     | ci-cd-and-automation         | Automated quality gates on every change                                                     |
| Ship     | deployment-hetzner-quadlets  | Provision Hetzner servers, Podman Quadlets, nginx, certbot                                  |
| Ship     | deprecation-and-migration    | Remove old systems and migrate users safely                                                 |
| Ship     | documentation-and-adrs       | Document the why, not just the what                                                         |
| Meta     | claude-janitor               | Audit skill descriptions, Handoffs sections, AGENTS.md, CLAUDE.md, and README.md            |

### Intent → Skill Mapping

```
Task arrives
    │
    ├── Don't know what you want yet? ──────→ interview-me
    ├── Have a rough concept, need variants? → idea-refine
    ├── New project / feature / change? ────→ spec-driven-development
    ├── Scaffolding a project type? ─────────→ cli-app-designer / go-web-project / go-cli-project
    ├── Minecraft plugin/mod work? ──────────→ minecraft-development
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

- **Skills** (`skills/<name>/SKILL.md`) — workflows with steps and exit criteria. The *how*. Mandatory hops when an
  intent matches.
- **Personas** (`agents/<role>.md`) — roles with a perspective and an output format. The *who*.
- **Slash commands** (`.claude/commands/<name>.md`) — user-facing entry points. The *when*. The orchestration layer.

Composition rule: **the user (or a slash command) is the orchestrator. Personas do not invoke other personas.** A
persona may invoke skills.

The only multi-persona orchestration pattern this repo endorses is **parallel fan-out with a merge step** — used by
`/preflight` to run `code-reviewer`, `security-auditor`, and `test-engineer` concurrently and synthesize their reports.
Do not build a "router" persona that decides which other persona to call; that's the job of slash commands and intent
mapping.

See [agents/README.md](agents/README.md) for the decision matrix
and [references/orchestration-patterns.md](references/orchestration-patterns.md) for the full pattern catalog.

**Claude Code interop:** the personas in `agents/` work as Claude Code subagents (auto-discovered from the `agents/`
directory) and as Agent Teams teammates (referenced by name when spawning). Two platform constraints align with our
rules: subagents cannot spawn other subagents, and teams cannot nest.

## Writing Style

When writing prose, comments, documentation, commit messages, PR descriptions, or chat responses, write in a plain,
direct, human style.

- Prefer text that sounds like a careful engineer wrote it, not like generated product copy.
- Do not add a summary paragraph that only repeats what was already said.
- Do not end with a generic offer like "Let me know if you need anything else."

### General voice

- Active voice. Short sentences. One idea per sentence.
- Explain the useful part first.
- Cut anything that does not add meaning.
- Let code examples carry the detail when they are clearer than prose.

### Technical writing

Prefer precise, practical wording.

Write:
"scratch images have no `/etc/passwd`, so name-based users won't work"

Instead of:
"Name-based users require `/etc/passwd`, which scratch images do not have"

Split sentences that contain "which", "that", or multiple "and" joins.
Avoid spec language (`must`/`should`) where normal prose is enough.

### Style anchor

When possible, match the user's own writing style from nearby files, commit messages, PR descriptions, comments, or
examples in the conversation.

Concrete examples override these abstract rules.
