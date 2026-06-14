---
name: test-driven-development
description: Drives development with tests. Use when implementing any logic, fixing any bug, or changing any behavior. Use when you need to prove that code works, when a bug report arrives, or when you're about to modify existing functionality.
---

# Test-Driven Development

## Overview

Write a failing test before writing the code that makes it pass. For bug fixes, reproduce the bug with a test before attempting a fix. Tests are proof — "seems right" is not done.

## When to Use

- Implementing any new logic or behavior
- Fixing any bug (the Prove-It Pattern)
- Modifying existing functionality
- Adding edge case handling
- Any change that could break existing behavior

**When NOT to use:** Pure configuration changes, documentation updates, or static content changes with no behavioral impact.

## The TDD Cycle

```
    RED                GREEN              REFACTOR
 Write a test    Write minimal code    Clean up the
 that fails  ──→  to make it pass  ──→  implementation  ──→  (repeat)
      │                  │                    │
      ▼                  ▼                    ▼
   Test FAILS        Test PASSES         Tests still PASS
```

### Step 1: RED — Write a Failing Test

Write the test first. It must fail. A test that passes immediately proves nothing.

```go
// RED: fails because TaskService.Create doesn't exist yet
func TestTaskService_Create(t *testing.T) {
    svc := NewTaskService(testDB(t))
    task, err := svc.Create(context.Background(), "Buy groceries")
    if err != nil {
        t.Fatal(err)
    }
    if task.ID == "" {
        t.Error("expected non-empty ID")
    }
    if task.Title != "Buy groceries" {
        t.Errorf("title = %q, want %q", task.Title, "Buy groceries")
    }
    if task.Status != StatusPending {
        t.Errorf("status = %q, want %q", task.Status, StatusPending)
    }
}
```

### Step 2: GREEN — Make It Pass

Write the minimum code to make the test pass. Don't over-engineer.

```go
func (s *TaskService) Create(ctx context.Context, title string) (*Task, error) {
    task := &Task{
        ID:        newID(),
        Title:     title,
        Status:    StatusPending,
        CreatedAt: time.Now(),
    }
    return task, s.db.InsertTask(ctx, task)
}
```

### Step 3: REFACTOR — Clean Up

With tests green, improve the code without changing behavior. Run tests after every refactor step.

## The Prove-It Pattern (Bug Fixes)

When a bug is reported, **do not start by fixing it.** Start by writing a test that reproduces it.

```
Bug report arrives
       │
       ▼
  Write a test that demonstrates the bug
       │
       ▼
  Test FAILS (confirming the bug exists)
       │
       ▼
  Implement the fix
       │
       ▼
  Test PASSES (proving the fix works)
       │
       ▼
  Run full test suite (check for regressions)
```

**Example:**

```go
// Bug: "completing a task doesn't update CompletedAt"

// Step 1: Write the reproduction test — it must FAIL
func TestCompleteTask_SetsCompletedAt(t *testing.T) {
    svc := NewTaskService(testDB(t))
    task, _ := svc.Create(context.Background(), "Test task")

    done, err := svc.Complete(context.Background(), task.ID)
    if err != nil {
        t.Fatal(err)
    }
    if done.Status != StatusCompleted {
        t.Errorf("status = %q, want completed", done.Status)
    }
    if done.CompletedAt.IsZero() {
        t.Error("CompletedAt should be set") // FAILS → bug confirmed
    }
}

// Step 2: Fix
func (s *TaskService) Complete(ctx context.Context, id string) (*Task, error) {
    now := time.Now()
    return s.db.UpdateTask(ctx, id, TaskUpdate{
        Status:      StatusCompleted,
        CompletedAt: &now,            // this was missing
    })
}

// Step 3: Test passes → bug fixed, regression guarded
```

## Table-Driven Tests

Use table-driven tests for cases that vary only in input/output. This is idiomatic Go and keeps the test suite concise without sacrificing readability.

```go
func TestCreateTask_TitleValidation(t *testing.T) {
    svc := NewTaskService(testDB(t))
    tests := []struct {
        name    string
        title   string
        wantErr bool
    }{
        {"empty title", "", true},
        {"whitespace only", "   ", true},
        {"valid title", "Buy groceries", false},
        {"max length", strings.Repeat("a", 200), false},
        {"too long", strings.Repeat("a", 201), true},
    }
    for _, tc := range tests {
        t.Run(tc.name, func(t *testing.T) {
            _, err := svc.Create(context.Background(), tc.title)
            if (err != nil) != tc.wantErr {
                t.Errorf("Create(%q) err=%v, wantErr=%v", tc.title, err, tc.wantErr)
            }
        })
    }
}
```

## The Test Pyramid

```
          ╱╲
         ╱  ╲         Integration / E2E Tests (~20%)
        ╱    ╲        Full flows, real database
       ╱──────╲
      ╱        ╲      Unit Tests (~80%)
     ╱          ╲     Pure logic, isolated, milliseconds each
    ╱────────────╲
```

### Test Sizes

| Size | Constraints | Speed | Example |
|------|------------|-------|---------|
| **Small** | Single process, no I/O, no network, no DB | Milliseconds | Pure function, data transform |
| **Medium** | Localhost only, in-process DB or test server | Seconds | Handler test with SQLite in-memory |
| **Large** | External services allowed | Minutes | End-to-end flow against real infra |

Small tests should dominate. They're fast, reliable, and easy to debug.

Use `go test -short` to skip large tests in fast feedback loops:

```go
func TestFullFlow(t *testing.T) {
    if testing.Short() {
        t.Skip("skipping integration test in short mode")
    }
    // ...
}
```

## Writing Good Tests

### Test State, Not Interactions

Assert on *outcomes*, not on which internal methods were called. Interaction-based tests break on refactor even when behavior is correct.

```go
// Good: tests what the function returns
func TestListTasks_SortedNewestFirst(t *testing.T) {
    tasks, err := svc.List(ctx, ListParams{Order: "desc"})
    if err != nil {
        t.Fatal(err)
    }
    if len(tasks) < 2 {
        t.Fatal("need at least 2 tasks")
    }
    if !tasks[0].CreatedAt.After(tasks[1].CreatedAt) {
        t.Error("tasks not sorted newest-first")
    }
}

// Bad: tests internal query construction
// Don't assert that db.QueryContext was called with "ORDER BY created_at DESC"
```

### DAMP Over DRY in Tests

In production code, DRY is usually right. In tests, **DAMP (Descriptive And Meaningful Phrases)** is better. Each test should tell a complete story.

```go
// DAMP: self-contained and readable
func TestCreateTask_EmptyTitle(t *testing.T) {
    _, err := NewTaskService(testDB(t)).Create(ctx, "")
    if err == nil {
        t.Error("expected error for empty title")
    }
}

func TestCreateTask_TrimsWhitespace(t *testing.T) {
    task, err := NewTaskService(testDB(t)).Create(ctx, "  Buy groceries  ")
    if err != nil {
        t.Fatal(err)
    }
    if task.Title != "Buy groceries" {
        t.Errorf("title = %q, want trimmed", task.Title)
    }
}
```

### Prefer Real Implementations Over Mocks

```
Preference order (most to least preferred):
1. Real implementation  → Highest confidence, catches real bugs
2. Fake (in-memory)     → e.g., in-process SQLite for DB tests
3. Stub                 → Returns canned data
4. Mock (interaction)   → Verifies call sequences — use sparingly
```

Use mocks only when the real implementation is too slow, non-deterministic, or has uncontrollable side effects (external APIs, email sending).

Over-mocking creates tests that pass while production breaks.

### Use the Arrange-Act-Assert Pattern

```go
func TestMarkOverdue(t *testing.T) {
    // Arrange
    task := &Task{
        Title:    "Test",
        Deadline: time.Date(2025, 1, 1, 0, 0, 0, 0, time.UTC),
    }

    // Act
    result := markOverdue(task, time.Date(2025, 1, 2, 0, 0, 0, 0, time.UTC))

    // Assert
    if !result.IsOverdue {
        t.Error("expected task to be overdue")
    }
}
```

### Name Tests Descriptively

```go
// Good: reads like a specification
func TestTaskService_Complete_SetsTimestamp(t *testing.T) { ... }
func TestTaskService_Complete_IdempotentOnAlreadyCompleted(t *testing.T) { ... }
func TestTaskService_Complete_NotFoundError(t *testing.T) { ... }

// Bad: vague
func TestComplete(t *testing.T) { ... }
func TestError(t *testing.T) { ... }
```

### Test Helpers

Use `t.Helper()` so failure lines point to the call site, not inside the helper.

```go
func requireNoError(t *testing.T, err error) {
    t.Helper()
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
}

func testDB(t *testing.T) *sql.DB {
    t.Helper()
    db, err := sql.Open("sqlite", ":memory:")
    if err != nil {
        t.Fatal(err)
    }
    t.Cleanup(func() { db.Close() })
    return db
}
```

## Running Tests

```bash
# Run all tests
go test ./...

# Run with race detector (always use in CI)
go test -race ./...

# Run a specific test
go test -run TestTaskService_Create ./...

# Run with verbose output
go test -v ./...

# Skip large/slow tests
go test -short ./...

# Run with coverage
go test -cover ./...
go test -coverprofile=coverage.out ./... && go tool cover -html=coverage.out
```

## Test Anti-Patterns to Avoid

| Anti-Pattern | Problem | Fix |
|---|---|---|
| Testing implementation details | Tests break on refactor even when behavior is unchanged | Test inputs and outputs |
| Flaky tests (timing, order-dependent) | Erodes trust in the suite | Use deterministic assertions, isolate test state |
| No test isolation | Tests pass alone but fail together | Each test sets up and tears down its own state |
| Mocking everything | Tests pass but production breaks | Prefer real implementations; mock only at boundaries |
| Shared mutable global state | Test pollution between cases | Use `t.Cleanup` and per-test setup |

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll write tests after the code works" | You won't. Tests written after the fact test implementation, not behavior. |
| "This is too simple to test" | Simple code gets complicated. The test documents the expected behavior. |
| "Tests slow me down" | Tests slow you down now. They speed you up every time you change the code later. |
| "I tested it manually" | Manual testing doesn't persist. Tomorrow's change might break it silently. |
| "Let me run the tests again just to be sure" | After a clean run, repeating adds nothing unless the code changed. Run again after edits, not as reassurance. |

## Red Flags

- Writing code without corresponding tests
- Tests that pass on the first run without being inverted first (may not test what you think)
- Bug fixes without reproduction tests
- Test names that don't describe expected behavior
- Skipping or disabling tests to make the suite pass
- Running the same test command twice without an intervening code change

## Reference

See `references/testing-patterns.md` for Go-specific patterns: table-driven tests, test helpers, HTTP handler testing, fakes vs mocks, testcontainers, CLI output testing, fuzz testing, and benchmarks.

## Verification

After completing any implementation:

- [ ] Every new behavior has a corresponding test
- [ ] All tests pass: `go test -race ./...`
- [ ] Bug fixes include a reproduction test that failed before the fix
- [ ] Test names describe the behavior being verified
- [ ] No tests were skipped or disabled
- [ ] Coverage hasn't decreased (if tracked)
