---
name: documentation-and-adrs
description: Record architectural decisions and write documentation. Use when making design changes, shipping features, or capturing context future engineers will need.
---

# Documentation and ADRs

## Overview

Document decisions, not just code. The most valuable documentation captures the *why* — the context, constraints, and trade-offs that led to a decision. Code shows *what* was built; documentation explains *why it was built this way* and *what alternatives were considered*. This context is essential for future humans and agents working in the codebase.

## When to Use

- Making a significant architectural decision
- Choosing between competing approaches
- Adding or changing a public API
- Shipping a feature that changes user-facing behavior
- Onboarding new team members (or agents) to the project
- When you find yourself explaining the same thing repeatedly

**When NOT to use:** Don't document obvious code. Don't add comments that restate what the code already says. Don't write docs for throwaway prototypes.

## Architecture Decision Records (ADRs)

ADRs capture the reasoning behind significant technical decisions. They're the highest-value documentation you can write.

### When to Write an ADR

- Choosing a framework, library, or major dependency
- Designing a data model or database schema
- Selecting an authentication strategy
- Deciding on an API architecture (REST vs. plain HTTP handlers vs. internal RPC)
- Choosing between build tools, hosting platforms, or infrastructure
- Any decision that would be expensive to reverse

### ADR Template

Store ADRs in `docs/adrs/` with sequential numbering:

```markdown
# ADR-001: Use PostgreSQL for primary database

## Status
Accepted | Superseded by ADR-XXX | Deprecated

## Date
2025-01-15

## Context
We need a primary database for the task management application. Key requirements:
- Relational data model (users, tasks, teams with relationships)
- ACID transactions for task state changes
- Support for full-text search on task content
- Managed hosting available (for small team, limited ops capacity)

## Decision
Use PostgreSQL with `database/sql` and the `pgx` driver.

## Alternatives Considered

### MongoDB
- Pros: Flexible schema, easy to start with
- Cons: Our data is inherently relational; would need to manage relationships manually
- Rejected: Relational data in a document store leads to complex joins or data duplication

### SQLite
- Pros: Zero configuration, embedded, fast for reads
- Cons: Limited concurrent write support
- Rejected: Not suitable for multi-user production service requiring concurrent writes

### MySQL
- Pros: Mature, widely supported
- Cons: PostgreSQL has better JSON support, full-text search, and ecosystem tooling
- Rejected: PostgreSQL is the better fit for our feature requirements

## Consequences
- `database/sql` + `pgx` gives type-safe access without an ORM
- We can use PostgreSQL's full-text search instead of adding a separate search service
- Team needs PostgreSQL knowledge (standard skill, low risk)
- Migrations managed via SQL files + `golang-migrate` or similar lightweight tool
```

### ADR Lifecycle

```
PROPOSED → ACCEPTED → (SUPERSEDED or DEPRECATED)
```

- **Don't delete old ADRs.** They capture historical context.
- When a decision changes, write a new ADR that references and supersedes the old one.

## Inline Documentation

### When to Comment

Comment the *why*, not the *what*:

```go
// BAD: Restates the code
// Increment counter by 1
counter++

// GOOD: Explains non-obvious intent
// Rate limit uses a sliding window — reset counter at window boundary,
// not on a fixed schedule, to prevent burst attacks at window edges
if time.Since(windowStart) > windowSize {
    counter = 0
    windowStart = time.Now()
}
```

### When NOT to Comment

```go
// Don't comment self-explanatory code
func calculateTotal(items []CartItem) float64 {
    var total float64
    for _, item := range items {
        total += item.Price * float64(item.Quantity)
    }
    return total
}

// Don't leave TODO comments for things you should just do now
// TODO: add error handling  ← Just add it

// Don't leave commented-out code
// oldImplementation()  ← Delete it, git has history
```

### Document Known Gotchas

```go
// LoadConfig must be called before any handler is registered.
// If called after the first request, the default config is already
// applied and changes will not take effect. See ADR-003.
func LoadConfig(path string) error {
    // ...
}
```

## API Documentation

For public APIs (REST, library interfaces):

### Go godoc

```go
// Create creates a new task. Title is required; description is optional.
// Returns the created task with a server-generated ID and timestamps.
// Returns ValidationError if title is empty or exceeds 200 characters.
//
// Example:
//
//	task, err := svc.Create(ctx, CreateTaskInput{Title: "Buy groceries"})
func (s *TaskService) Create(ctx context.Context, input CreateTaskInput) (*Task, error) {
    // ...
}
```

## README Structure

Every project should have a README that covers:

```markdown
# Project Name

One-paragraph description of what this project does.

## Quick Start
1. Clone the repo
2. Set up environment: `cp .env.example .env`
3. Run: `go run ./cmd/app`

## Commands
| Command | Description |
|---------|-------------|
| `go run ./cmd/app` | Start development server |
| `go test ./...` | Run tests |
| `go build ./...` | Build |
| `go vet ./...` | Run vet |

## Architecture
Brief overview of the project structure and key design decisions.
Link to ADRs for details.

## Contributing
How to contribute, coding standards, PR process.
```

## Changelog Maintenance

For shipped features:

```markdown
# Changelog

## [1.2.0] - 2025-01-20
### Added
- Task sharing: users can share tasks with team members (#123)
- Email notifications for task assignments (#124)

### Fixed
- Duplicate tasks appearing when rapidly clicking create button (#125)

### Changed
- Task list now loads 50 items per page (was 20) for better UX (#126)
```

## Documentation for Agents

Special consideration for AI agent context:

- **CLAUDE.md / rules files** — Document project conventions so agents follow them
- **Spec files** — Keep specs updated so agents build the right thing
- **ADRs** — Help agents understand why past decisions were made (prevents re-deciding)
- **Inline gotchas** — Prevent agents from falling into known traps

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The code is self-documenting" | Code shows what. It doesn't show why, what alternatives were rejected, or what constraints apply. |
| "We'll write docs when the API stabilizes" | APIs stabilize faster when you document them. The doc is the first test of the design. |
| "Nobody reads docs" | Agents do. Future engineers do. Your 3-months-later self does. |
| "ADRs are overhead" | A 10-minute ADR prevents a 2-hour debate about the same decision six months later. |
| "Comments get outdated" | Comments on *why* are stable. Comments on *what* get outdated — that's why you only write the former. |

## Red Flags

- Architectural decisions with no written rationale
- Public APIs with no documentation or types
- README that doesn't explain how to run the project
- Commented-out code instead of deletion
- TODO comments that have been there for weeks
- No ADRs in a project with significant architectural choices
- Documentation that restates the code instead of explaining intent

## Verification

After documenting:

- [ ] ADRs exist for all significant architectural decisions
- [ ] README covers quick start, commands, and architecture overview
- [ ] API functions have parameter and return type documentation
- [ ] Known gotchas are documented inline where they matter
- [ ] No commented-out code remains
- [ ] Rules files (CLAUDE.md etc.) are current and accurate
