---
name: git-workflow-and-versioning
description: Structure git workflow practices. Use when committing, branching, resolving conflicts, or when you need to organize work across multiple parallel streams.
---

# Git Workflow and Versioning

## Overview

Git is your safety net. Treat commits as save points, branches as sandboxes, and history as documentation. With AI agents generating code at high speed, disciplined version control is the mechanism that keeps changes manageable, reviewable, and reversible.

## When to Use

Always. Every code change flows through git.

## Core Principles

### Branching Strategy

Two strategies are in use depending on the project. Both are valid. The commit discipline (atomic, conventional, small) matters more than the specific strategy.

**Trunk-based** — for small, fast-moving projects or solo work:

```
main ──●──●──●──●──●──●──●──●──●──  (always deployable)
        ╲      ╱  ╲    ╱
         ●──●─╱    ●──╱    ← short-lived feature branches (1-3 days)
```

**Gitflow** — for projects with planned releases or multiple parallel workstreams:

```
main     ──────────────────●────────●──  (release tags only)
develop  ──●──●──────────●─┘ ●──●──┘
feat/x        ╲──●──●──●╱
feat/y                    ╲──●──●──╱
```

Pick one strategy per project at the start. Don't mix.

Common principles for both:
- **Dev branches are costs.** Every day a branch lives, it accumulates merge risk.
- **Release branches are acceptable.** When stabilizing a release while development continues.
- **Feature flags > long branches.** Deploy incomplete work behind a flag rather than keeping it on a branch for weeks.

### 1. Commit Early, Commit Often

Each successful increment gets its own commit. Don't accumulate large uncommitted changes.

```
Work pattern:
  Implement slice → Test → Verify → Commit → Next slice

Not this:
  Implement everything → Hope it works → Giant commit
```

Commits are save points. If the next change breaks something, you can revert to the last known-good state instantly.

### 2. Atomic Commits

Each commit does one logical thing:

```
# Good: Each commit is self-contained
git log --oneline
a1b2c3d Add task creation endpoint with validation
d4e5f6g Add task creation handler and route registration
h7i8j9k Add task service with database integration
m1n2o3p Add task creation tests (unit + integration)

# Bad: Everything mixed together
git log --oneline
x1y2z3a Add task feature, fix sidebar, update deps, refactor utils
```

### 3. Descriptive Messages

Commit messages explain the *why*, not just the *what*:

```
# Good: Explains intent
feat: add email validation to registration endpoint

Prevents invalid email formats from reaching the database.
Validates at the handler level, consistent with existing
patterns in internal/handler/auth.go.

# Bad: Describes what's obvious from the diff
update auth.ts
```

**Format:**
```
<type>: <short description>

<optional body explaining why, not what>
```

**Types:**
- `feat` — New feature
- `fix` — Bug fix
- `refactor` — Code change that neither fixes a bug nor adds a feature
- `test` — Adding or updating tests
- `docs` — Documentation only
- `chore` — Tooling, dependencies, config

### 4. Keep Concerns Separate

Don't combine formatting changes with behavior changes. Don't combine refactors with features. Each type of change should be a separate commit — and ideally a separate PR:

```
# Good: Separate concerns
git commit -m "refactor: extract validation logic to shared utility"
git commit -m "feat: add phone number validation to registration"

# Bad: Mixed concerns
git commit -m "refactor validation and add phone number field"
```

**Separate refactoring from feature work.** A refactoring change and a feature change are two different changes — submit them separately. This makes each change easier to review, revert, and understand in history. Small cleanups (renaming a variable) can be included in a feature commit at reviewer discretion.

### 5. Size Your Changes

Target ~100 lines per commit/PR. Changes over ~1000 lines should be split. See the splitting strategies in `code-review-and-quality` for how to break down large changes.

```
~100 lines  → Easy to review, easy to revert
~300 lines  → Acceptable for a single logical change
~1000 lines → Split into smaller changes
```

## Branching Strategy

### Feature Branches

```
main (always deployable)
  │
  ├── feature/task-creation    ← One feature per branch
  ├── feature/user-settings    ← Parallel work
  └── fix/duplicate-tasks      ← Bug fixes
```

- Branch from `main` (or the team's default branch)
- Keep branches short-lived (merge within 1-3 days) — long-lived branches are hidden costs
- Delete branches after merge
- Prefer feature flags over long-lived branches for incomplete features

### Branch Naming

```
feature/<short-description>   → feature/task-creation
fix/<short-description>       → fix/duplicate-tasks
chore/<short-description>     → chore/update-deps
refactor/<short-description>  → refactor/auth-module
```

## Semver Releases and Changelog

Releases follow [Semantic Versioning](https://semver.org/). Version number is determined by the conventional commit types since the last tag:

| Commits since last tag | Bump |
|---|---|
| `fix:` only | patch (1.0.0 → 1.0.1) |
| any `feat:` | minor (1.0.0 → 1.1.0) |
| any `feat!:` or `BREAKING CHANGE:` footer | major (1.0.0 → 2.0.0) |

### Tagging a release

```bash
# See what version git-cliff would bump to
git-cliff --bumped-version

# Generate changelog for this release
git-cliff --current --strip header -o CHANGES.md

# Review, then tag
VERSION=$(git-cliff --bumped-version)
git tag -s "$VERSION" -m "$VERSION"
git push origin "$VERSION"
```

The signed tag triggers the CI release job.

### git-cliff config

A minimal `cliff.toml` template lives in `references/ci-pipeline-templates.md` — read it when setting up changelog generation for a new project.

## Working with Worktrees

For parallel AI agent work, use git worktrees to run multiple branches simultaneously:

```bash
# Create a worktree for a feature branch
git worktree add ../project-feature-a feature/task-creation
git worktree add ../project-feature-b feature/user-settings

# Each worktree is a separate directory with its own branch
# Agents can work in parallel without interfering
ls ../
  project/              ← main branch
  project-feature-a/    ← task-creation branch
  project-feature-b/    ← user-settings branch

# When done, merge and clean up
git worktree remove ../project-feature-a
```

Benefits:
- Multiple agents can work on different features simultaneously
- No branch switching needed (each directory has its own branch)
- If one experiment fails, delete the worktree — nothing is lost
- Changes are isolated until explicitly merged

## The Save Point Pattern

```
Agent starts work
    │
    ├── Makes a change
    │   ├── Test passes? → Commit → Continue
    │   └── Test fails? → Revert to last commit → Investigate
    │
    ├── Makes another change
    │   ├── Test passes? → Commit → Continue
    │   └── Test fails? → Revert to last commit → Investigate
    │
    └── Feature complete → All commits form a clean history
```

This pattern means you never lose more than one increment of work. If an agent goes off the rails, `git reset --hard HEAD` takes you back to the last successful state.

## Change Summaries

After any modification, provide a structured summary. This makes review easier, documents scope discipline, and surfaces unintended changes:

```
CHANGES MADE:
- internal/handler/task.go: Added input validation to POST /tasks endpoint
- internal/validator/task.go: Added TaskCreateValidator

THINGS I DIDN'T TOUCH (intentionally):
- internal/handler/auth.go: Has similar validation gap but out of scope
- internal/middleware/error.go: Error format could be improved (separate task)

POTENTIAL CONCERNS:
- Validator rejects unknown fields — confirm this is desired.
- Using regexp for email validation rather than net/mail.ParseAddress — simpler but less strict.
```

This pattern catches wrong assumptions early and gives reviewers a clear map of the change. The "DIDN'T TOUCH" section is especially important — it shows you exercised scope discipline and didn't go on an unsolicited renovation.

## Pre-Commit Hygiene

Before every commit:

```bash
# 1. Check what you're about to commit
git diff --staged

# 2. Ensure no secrets
git diff --staged | grep -iE "password|secret|api_key|token"

# 3. Run language-specific checks before committing
#    Go:    go fmt ./... && go test -vet=all ./...
#    Shell: shellcheck <changed files>
#    Any:   whatever the project's pre-commit sequence is
```

Automate with a git pre-commit hook in `.git/hooks/pre-commit`:

```sh
#!/bin/sh
set -e
go fmt ./...
go test -vet=all ./...
```

## Handling Generated Files

- **Commit generated files** only if the project expects them (e.g., `go.sum`, SQL migrations)
- **Don't commit** build output (compiled binaries, `dist/`), environment files (`.env`), or IDE config (`.vscode/settings.json` unless shared)
- **Have a `.gitignore`** that covers at minimum: compiled binary, `.env`, `*.pem`, editor temp files

Go-specific `.gitignore` baseline:

```
/{{project-name}}
*.test
*.out
.env
```

## Using Git for Debugging

```bash
# Find which commit introduced a bug
git bisect start
git bisect bad HEAD
git bisect good <known-good-commit>
# Git checkouts midpoints; run your test at each to narrow down

# View what changed recently
git log --oneline -20
git diff HEAD~5..HEAD -- src/

# Find who last changed a specific line
git blame internal/service/task.go

# Search commit messages for a keyword
git log --grep="validation" --oneline
```

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll commit when the feature is done" | One giant commit is impossible to review, debug, or revert. Commit each slice. |
| "The message doesn't matter" | Messages are documentation. Future you (and future agents) will need to understand what changed and why. |
| "I'll squash it all later" | Squashing destroys the development narrative. Prefer clean incremental commits from the start. |
| "Branches add overhead" | Short-lived branches are free and prevent conflicting work from colliding. Long-lived branches are the problem — merge within 1-3 days. |
| "I'll split this change later" | Large changes are harder to review, riskier to deploy, and harder to revert. Split before submitting, not after. |
| "I don't need a .gitignore" | Until `.env` with production secrets gets committed. Set it up immediately. |

## Red Flags

- Large uncommitted changes accumulating
- Commit messages like "fix", "update", "misc"
- Formatting changes mixed with behavior changes
- No `.gitignore` in the project
- Committing `.env`, build binaries, or generated artifacts that belong in `.gitignore`
- Long-lived branches that diverge significantly from main
- Force-pushing to shared branches

## Handoffs

- **Upstream:** `code-review-and-quality` — commit only after review passes
- **Pair:** `ci-cd-and-automation` — if pipelines need setup or updating alongside the commit
- **Downstream:** `deployment-hetzner-quadlets` — for deploy after a release tag

## Verification

For every commit:

- [ ] Commit does one logical thing
- [ ] Message explains the why, follows type conventions
- [ ] Tests pass before committing
- [ ] No secrets in the diff
- [ ] No formatting-only changes mixed with behavior changes
- [ ] `.gitignore` covers standard exclusions
