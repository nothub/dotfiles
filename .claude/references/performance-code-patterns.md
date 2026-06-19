# Performance Code Patterns

Go implementation patterns for common bottlenecks. Use alongside the `performance-optimization` skill; see `performance-checklist.md` for the review checklist these patterns satisfy.

## N+1 Queries

```go
// BAD: one query per item
for _, id := range taskIDs {
    task, _ := db.QueryRow("SELECT * FROM tasks WHERE id = ?", id)
}

// GOOD: single query
rows, _ := db.Query("SELECT * FROM tasks WHERE id = ANY($1)", pq.Array(taskIDs))
```

## Unbounded Data Fetching

```go
// BAD: loads all rows
rows, _ := db.Query("SELECT * FROM tasks")

// GOOD: paginated
rows, _ := db.Query("SELECT * FROM tasks ORDER BY created_at DESC LIMIT $1 OFFSET $2", limit, offset)
```

## Missing Database Indexes

```sql
-- Find slow queries in Postgres
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 20;

-- Add index on frequent filter columns
CREATE INDEX CONCURRENTLY ON tasks (user_id, status);
```

## In-Memory Caching

```go
// Cache frequently-read, rarely-changed data
type cache[T any] struct {
    mu      sync.RWMutex
    val     T
    expires time.Time
    ttl     time.Duration
}

func (c *cache[T]) get(fetch func() (T, error)) (T, error) {
    c.mu.RLock()
    if time.Now().Before(c.expires) {
        v := c.val
        c.mu.RUnlock()
        return v, nil
    }
    c.mu.RUnlock()
    c.mu.Lock()
    defer c.mu.Unlock()
    v, err := fetch()
    if err == nil {
        c.val, c.expires = v, time.Now().Add(c.ttl)
    }
    return v, err
}
```

## Goroutine Leaks

```go
// BAD: goroutine leaks if nobody reads the channel
go func() { results <- expensiveOp() }()

// GOOD: use context for cancellation
ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
defer cancel()
go func() {
    select {
    case results <- expensiveOp():
    case <-ctx.Done():
    }
}()
```

## HTTP Response Caching

```go
// Static assets: long cache with content hash in URL
w.Header().Set("Cache-Control", "public, max-age=31536000, immutable")

// API responses that change infrequently
w.Header().Set("Cache-Control", "public, max-age=300")

// Per-user data: never cache at proxy
w.Header().Set("Cache-Control", "private, no-store")
```
