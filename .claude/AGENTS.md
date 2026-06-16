# Global Agent Instructions

This file provides global guidance to AI agents.

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

## Workflow Artifacts

Keep agent workflow artifacts in the project's `.ai/` directory. General documentation (architecture, tradeoffs, decisions) goes in `docs/`.

**Naming rule: `{type}-{qualifier}.md`**

- **type** — artifact kind: `spec`, `plan`, `tasks`, `review`
- **qualifier** — feature/scope, phase, persona, or date: `user-auth`, `phase-2`, `security`, `20240616`

Examples: `.ai/spec-user-auth.md`, `.ai/plan-user-auth.md`, `.ai/tasks-user-auth.md`, `.ai/review-preflight.md`

Type comes first so `ls .ai/` groups by artifact kind and `review-<tab>` lists all reviews. No bare names — every file has a qualifier.

Commands that read or write `.ai/` files accept a qualifier argument (e.g. `/spec user-auth`, `/build user-auth`). If no qualifier is given and exactly one matching artifact exists, use it automatically; if multiple exist, ask.

## Skill-Driven Execution

When a task matches a skill, invoke it. Each skill's `description:` frontmatter states when it applies — read those to route correctly. Never implement directly if a skill applies; always follow the skill workflow exactly.

If a request is underspecified, start with `interview-me`. For any new project or feature, start with `spec-driven-development` before touching code.

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

See [references/orchestration-patterns.md](references/orchestration-patterns.md) for the full pattern catalog.

**Claude Code interop:** the personas in `agents/` work as Claude Code subagents (auto-discovered from the `agents/`
directory) and as Agent Teams teammates (referenced by name when spawning). Two platform constraints align with our
rules: subagents cannot spawn other subagents, and teams cannot nest.

As subagents, use the Agent tool with `subagent_type: <role>` (e.g. `code-reviewer`). `/preflight` is the canonical
example. As Agent Teams teammates (experimental, requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`), reference the
persona by name — the persona body is appended to the teammate's system prompt, not a replacement.

Subagents report results back to the main agent only. Agent Teams let teammates message each other directly. Use
subagents when reports are enough; use Agent Teams when sub-agents need to challenge each other's findings.

Plugin agents do not support `hooks`, `mcpServers`, or `permissionMode` frontmatter — those fields are silently ignored.

## Writing Style

Plain, direct, engineer voice — not generated product copy. Active voice. Short sentences. One idea per sentence. Explain the useful part first. Cut anything that adds no meaning.

State the constraint before the consequence: "scratch images have no `/etc/passwd`, so name-based users won't work" — not the reverse. Avoid `must`/`should` in prose. No summary paragraph that repeats what was already said. No closing offer ("Let me know if you need anything else").

Match the user's writing style from nearby files, commit messages, or examples in the conversation. Concrete examples override these rules.
