# Testing Patterns Reference (Go)

Quick reference for common Go testing patterns. Use alongside the `test-driven-development` skill.

## Test Structure (Arrange-Act-Assert)

```go
func TestCreateTask_TrimsTitle(t *testing.T) {
    // Arrange
    svc := NewTaskService(testDB(t))

    // Act
    task, err := svc.Create(context.Background(), "  Buy groceries  ")

    // Assert
    if err != nil {
        t.Fatal(err)
    }
    if task.Title != "Buy groceries" {
        t.Errorf("title = %q, want trimmed", task.Title)
    }
}
```

## Test Naming

```go
// Pattern: Test[Type]_[Method]_[Condition]
func TestTaskService_Create_EmptyTitle(t *testing.T) {}
func TestTaskService_Complete_SetsTimestamp(t *testing.T) {}
func TestTaskService_Complete_IdempotentOnAlreadyCompleted(t *testing.T) {}
func TestListHandler_ReturnsJSON(t *testing.T) {}
func TestListHandler_Returns401WithoutToken(t *testing.T) {}
```

## Table-Driven Tests

```go
func TestCreateTask_TitleValidation(t *testing.T) {
    tests := []struct {
        name    string
        title   string
        wantErr bool
    }{
        {"empty", "", true},
        {"whitespace only", "   ", true},
        {"valid", "Buy groceries", false},
        {"max length", strings.Repeat("a", 200), false},
        {"too long", strings.Repeat("a", 201), true},
    }
    for _, tc := range tests {
        t.Run(tc.name, func(t *testing.T) {
            _, err := NewTaskService(testDB(t)).Create(context.Background(), tc.title)
            if (err != nil) != tc.wantErr {
                t.Errorf("Create(%q) err=%v, wantErr=%v", tc.title, err, tc.wantErr)
            }
        })
    }
}
```

## Subtests

```go
func TestTaskService(t *testing.T) {
    t.Run("Create", func(t *testing.T) { ... })
    t.Run("Complete", func(t *testing.T) { ... })
    t.Run("Delete", func(t *testing.T) { ... })
}
```

Run a single subtest: `go test -run TestTaskService/Complete`

## Test Helpers

```go
// t.Helper() makes failure lines point to the call site, not inside the helper
func requireNoError(t *testing.T, err error) {
    t.Helper()
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
}

// t.Cleanup runs after the test regardless of pass/fail
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

## HTTP Handler Testing

```go
func TestCreateHandler(t *testing.T) {
    svc := NewTaskService(testDB(t))
    h := NewHandler(svc)

    body := strings.NewReader(`{"title":"Buy groceries"}`)
    req := httptest.NewRequest(http.MethodPost, "/tasks", body)
    req.Header.Set("Content-Type", "application/json")
    w := httptest.NewRecorder()

    h.ServeHTTP(w, req)

    if w.Code != http.StatusCreated {
        t.Errorf("status = %d, want %d", w.Code, http.StatusCreated)
    }

    var resp Task
    if err := json.NewDecoder(w.Body).Decode(&resp); err != nil {
        t.Fatal(err)
    }
    if resp.Title != "Buy groceries" {
        t.Errorf("title = %q, want %q", resp.Title, "Buy groceries")
    }
}
```

## Fakes vs Mocks

```
Preference order:
1. Real implementation via testcontainers — highest confidence, production-equivalent
2. In-memory fake                        — e.g. SQLite :memory: when Docker unavailable
3. Interface stub                        — returns canned data for a specific test
4. Interaction mock                      — verifies call sequences; use sparingly
```

Write fakes as concrete types implementing the same interface:

```go
type fakeMailer struct {
    sent []Mail
}

func (m *fakeMailer) Send(mail Mail) error {
    m.sent = append(m.sent, mail)
    return nil
}
```

Mock only at true system boundaries: external APIs, email, time, random. Never mock between internal packages.

## Integration Tests with Testcontainers

Use `testcontainers-go` to run real services in Docker during tests. Prefer this over mocking databases, queues, or any external system where behavior differences matter.

```
go get github.com/testcontainers/testcontainers-go
go get github.com/testcontainers/testcontainers-go/modules/postgres
```

### Container lifecycle — choose based on test requirements

Two patterns. Neither is always right.

**Fresh container per test** — maximum isolation, slower. Use when tests mutate state in ways that are hard to clean up, or when the service itself needs to start in a specific state.

```go
func TestTaskStore_Integration(t *testing.T) {
    if testing.Short() {
        t.Skip("skipping integration test: requires Docker")
    }

    ctx := context.Background()

    ctr, err := postgres.Run(ctx,
        "postgres:16-alpine",
        postgres.WithDatabase("testdb"),
        postgres.WithUsername("test"),
        postgres.WithPassword("test"),
        testcontainers.WithWaitStrategy(
            wait.ForLog("database system is ready to accept connections").
                WithOccurrence(2).
                WithStartupTimeout(30*time.Second),
        ),
    )
    if err != nil {
        t.Fatal(err)
    }
    t.Cleanup(func() { ctr.Terminate(ctx) })

    connStr, err := ctr.ConnectionString(ctx, "sslmode=disable")
    if err != nil {
        t.Fatal(err)
    }

    db, err := sql.Open("pgx", connStr)
    if err != nil {
        t.Fatal(err)
    }
    t.Cleanup(func() { db.Close() })

    store := NewTaskStore(db)
    // run migrations, then test
}
```

**Shared container via TestMain** — one container for the whole package, faster startup. Use when tests can share the service and isolate their data by truncating tables or using separate schemas in `t.Cleanup`.

```go
var testConnStr string

func TestMain(m *testing.M) {
    ctx := context.Background()

    ctr, err := postgres.Run(ctx,
        "postgres:16-alpine",
        postgres.WithDatabase("testdb"),
        postgres.WithUsername("test"),
        postgres.WithPassword("test"),
        testcontainers.WithWaitStrategy(
            wait.ForLog("database system is ready to accept connections").
                WithOccurrence(2).
                WithStartupTimeout(30*time.Second),
        ),
    )
    if err != nil {
        log.Fatalf("start postgres: %v", err)
    }
    defer ctr.Terminate(ctx)

    testConnStr, err = ctr.ConnectionString(ctx, "sslmode=disable")
    if err != nil {
        log.Fatalf("connection string: %v", err)
    }

    os.Exit(m.Run())
}
```

### Available modules

| Module | Import path |
|--------|-------------|
| PostgreSQL | `testcontainers-go/modules/postgres` |
| Redis | `testcontainers-go/modules/redis` |
| Generic | `testcontainers-go` — use `GenericContainer` for anything else |

For services without a dedicated module, use `GenericContainer`:

```go
req := testcontainers.ContainerRequest{
    Image:        "minio/minio:latest",
    ExposedPorts: []string{"9000/tcp"},
    Cmd:          []string{"server", "/data"},
    WaitingFor:   wait.ForHTTP("/minio/health/live").WithPort("9000"),
}
ctr, err := testcontainers.GenericContainer(ctx, testcontainers.GenericContainerRequest{
    ContainerRequest: req,
    Started:          true,
})
```

### Rules

- Always skip with `testing.Short()` — container tests require Docker and are slow
- Terminate containers in `t.Cleanup` or `defer` in `TestMain`, never leak them
- Isolate test data per test — truncate tables or use separate schemas, not a shared dirty state
- Pin the image tag (`postgres:16-alpine`, not `postgres:latest`) for reproducibility

## Skipping Slow Tests

```go
func TestFullFlow(t *testing.T) {
    if testing.Short() {
        t.Skip("skipping integration test")
    }
    // ...
}
```

```bash
go test -short ./...   # skips anything that calls t.Skip in short mode
```

## Parallel Tests

```go
func TestSomething(t *testing.T) {
    t.Parallel() // safe only when test state is fully isolated
    // ...
}
```

Only use `t.Parallel()` when the test has no shared mutable state.

## Common go test Flags

```bash
go test ./...                          # run all tests
go test -race ./...                    # race detector (always use in CI)
go test -run TestTaskService ./...     # run matching tests
go test -run TestTaskService/Complete  # run matching subtest
go test -short ./...                   # skip slow/integration tests
go test -count=1 ./...                 # disable test caching
go test -cover ./...                   # show coverage summary
go test -coverprofile=c.out ./... && go tool cover -html=c.out  # coverage report
go test -v ./...                       # verbose output
```

## Test Anti-Patterns

| Anti-Pattern | Problem | Fix |
|---|---|---|
| Testing implementation details | Breaks on refactor when behavior is unchanged | Test inputs and outputs only |
| Mocking internal packages | Tight coupling to implementation | Mock only at system boundaries |
| Shared mutable global state | Tests pollute each other | Per-test setup via `t.Cleanup` |
| No `t.Helper()` in helpers | Failure lines point inside helpers | Add `t.Helper()` to every test helper |
| `t.Parallel()` with shared state | Race conditions, flaky tests | Isolate state or remove `t.Parallel()` |
| Re-running tests without code changes | Adds nothing after a clean run | Run again only after edits |
| Skipping tests to pass CI | Hides real bugs | Fix or delete the test |
