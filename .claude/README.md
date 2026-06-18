# ~/.claude

Personal AI coding-agent config for Claude Code: skills, commands, agent personas, and references.

- [`CLAUDE.md`](./CLAUDE.md) sets the global personality.
- [`AGENTS.md`](./AGENTS.md) defines the behavior rules and skill-driven execution model.
- [Skills](./skills) are engineering workflow processes loaded on demand.
- [Commands](./commands) are slash-command entry points.
- [Personas](./agents) run as subagents via the Agent tool.

## Ideal usage patterns

Three rules of thumb for how this config is meant to be driven, distilled from working out the orchestration model:

- **User-as-orchestrator for lifecycle work.** Multi-step work with real decision points (spec → plan → build → test → review → ship) is driven by you running slash commands in sequence, not by an agent chaining them on your behalf. An automated lifecycle orchestrator would lose the human checkpoints that catch wrong-direction work early and double the token cost via hand-off summarization. See Pattern 4 in [`references/orchestration-patterns.md`](references/orchestration-patterns.md).
- **Distributed routing via descriptions for everything else.** For single-shot or unclear-shape requests, just describe what you want in plain language. There's no central intent→skill flowchart — each skill's `description:` frontmatter is the routing entry, and Claude matches your phrasing against it directly. Typing a command and describing intent in chat both reach the same skill; commands exist to save retyping a repeated setup, not because routing requires them.
- **Parallel fan-out reserved for genuinely independent personas.** Multiple personas only run concurrently when their findings are independent and a merge step adds value — `/preflight` is the only example in this repo. It costs N context windows where direct invocation costs one, so it's not a default, it's a deliberate exception.

## Skills vs. personas: context model

The two get invoked similarly but run in fundamentally different places:

- **Skills** run inline, in whichever agent invoked them. No new session starts — the skill's steps are followed in the current context window, with full access to everything already there: conversation history, files already read, prior tool results.
- **Personas** run as subagents. Claude Code starts a separate, fresh context window for them with no view into your conversation history — only the persona's own system prompt, a task message, and the project's `CLAUDE.md`/git status. Only the persona's final report comes back to the main session; everything it explored along the way stays in its own context and is gone once it returns.

This is why `/quality-review`, `/test`, and `/code-simplify` — commands that invoke a skill — run entirely in your current session at no extra context cost, while `/preflight` — which spawns the `code-reviewer`, `security-auditor`, and `test-engineer` personas — pays for three separate context windows that start blind to anything not explicitly passed in.

## Commands

| Command           | What it does                                                                              | Call flow                                                                |
|-------------------|-------------------------------------------------------------------------------------------|--------------------------------------------------------------------------|
| `/spec`           | Write a structured specification before writing any code                                  | `spec-driven-development`                                                |
| `/plan`           | Turn a spec into an adversarially stress-tested task breakdown, ready for approval        | `planning-and-task-breakdown` → `doubt-driven-development` → approval    |
| `/build`          | Requires a spec; generates a plan if none exists, then implements every task with TDD     | [`planning-and-task-breakdown` →] approval → RED→GREEN→commit (×n tasks) |
| `/test`           | Write failing tests first, implement to pass, verify no regressions                       | `test-driven-development`                                                |
| `/quality-review` | Five-axis code review: correctness, readability, architecture, security, performance      | `code-review-and-quality`                                                |
| `/code-simplify`  | Reduce complexity, then verify clean — no Critical or Important findings remain           | `code-simplification` → `code-review-and-quality` (×3)                   |
| `/preflight`      | Pre-release quality gate: review, security, and coverage → go/no-go; build artifact on GO | `code-reviewer` ∥ `security-auditor` ∥ `test-engineer` → merge           |
| `/claude-janitor` | Audit and maintain this `.claude/` directory                                              | `claude-janitor`                                                         |

## Orchestration commands

These commands orchestrate multiple skills or personas. They are the only entry points for multi-step automated work.

### `/plan` — sequential chain with adversarial stress-test

Generates a task breakdown, then applies `doubt-driven-development` to find gaps before the user ever sees it.

```
/plan
  ├── Phase 1: planning-and-task-breakdown → Plan + Tasks sections in docs/ai/{date}-{qualifier}.md
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

Pre-release quality gate. Three specialist personas run concurrently, then results are merged into a go/no-go decision. Personas are required here — skills run inside the main agent's context and cannot be parallelized; only subagents (personas) can run concurrently.

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

## Adding a new command

1. Create `commands/<name>.md` with the prompt/instructions for the slash command.
2. Add a row to the Commands table in this file.
3. If it orchestrates multiple skills or personas, add a section below the table describing the call flow.

## Skills

**Routing is distributed.** There is no central intent→skill flowchart. Each skill's `description:` frontmatter is the routing entry — an agent reading only that line must be able to decide whether to invoke the skill. When writing a description: name the triggering intent first, mention any sibling sub-skills that branch from this one, and keep it under 200 chars.

The `claude-janitor` skill audits this invariant: it verifies every description is self-sufficient and that parent→sub-skill relationships are stated.

**Distributed routing only works if every description is actually visible to Claude.** The `skillListingBudgetFraction` setting (in `settings.json`) caps what fraction of the context window the skill listing may use — default `0.01` (1%). When the full listing exceeds that budget, Claude Code truncates it by collapsing the least-used skills' descriptions down to bare names: the skill is still invocable, but Claude can no longer see *why* it would apply, which silently breaks distributed routing for exactly the skills that need a description most. With 34 skills here, the 1% default truncated 17 descriptions to nothing; this repo currently runs at `0.03` (3%) while that's being tuned. Run `/doctor` to see the current truncation count and which skills are affected — if any are, raise the fraction further or shorten the longest descriptions first.

### Adding a new skill

1. Create `skills/<name>/SKILL.md` with the workflow steps and exit criteria.
2. Write a `description:` that answers "when would I reach for this?" — no other routing registration is needed.

### Adding a new persona

1. Create `agents/<role>.md` with the same frontmatter format used by existing personas.
2. Define the role, scope, output format, and rules.
3. Add a **Composition** block at the bottom (invoke directly when / invoke via / do not invoke from another persona).
4. Add a row to the `agents/README.md` table.
5. If the persona enables a new orchestration pattern, document it in `references/orchestration-patterns.md`.
6. Run the `/claude-janitor` command.
