---
name: performance-optimization
description: Optimize application performance. Use when profiling reveals bottlenecks, when response times exceed SLAs, or when you suspect a regression. Measure first — never optimize without data.
---

# Performance Optimization

## Overview

Measure before optimizing. Profile first, find the actual bottleneck, fix it, measure again. Optimization without measurement is guessing and adds complexity for nothing.

## When to Use

- Response time SLAs are being violated
- Users or monitoring report slow behavior
- A change introduced a measurable regression
- Features handle large datasets or high traffic

**When NOT to use:** Without profiling data showing an actual problem.

## The Workflow

```
1. MEASURE  → Establish baseline with real data
2. IDENTIFY → Find the actual bottleneck (not assumed)
3. FIX      → Address the specific bottleneck
4. VERIFY   → Measure again, confirm improvement
5. GUARD    → Add a benchmark or test to prevent regression
```

## Profiling Go Applications

```bash
# HTTP pprof endpoint (add to your server in dev/staging)
import _ "net/http/pprof"

# CPU profile: 30-second sample
go tool pprof http://localhost:6060/debug/pprof/profile?seconds=30

# Heap profile
go tool pprof http://localhost:6060/debug/pprof/heap

# Goroutine profile (leak detection)
go tool pprof http://localhost:6060/debug/pprof/goroutine

# Benchmark a specific function
go test -bench=BenchmarkFoo -benchmem ./...

# Race detector (catches data races that cause intermittent slowness)
go test -race ./...
```

## Common Bottlenecks

### N+1 Queries

```go
// BAD: one query per item
for _, id := range taskIDs {
    task, _ := db.QueryRow("SELECT * FROM tasks WHERE id = ?", id)
}

// GOOD: single query
rows, _ := db.Query("SELECT * FROM tasks WHERE id = ANY($1)", pq.Array(taskIDs))
```

### Unbounded Data Fetching

```go
// BAD: loads all rows
rows, _ := db.Query("SELECT * FROM tasks")

// GOOD: paginated
rows, _ := db.Query("SELECT * FROM tasks ORDER BY created_at DESC LIMIT $1 OFFSET $2", limit, offset)
```

### Missing Database Indexes

```sql
-- Find slow queries in Postgres
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 20;

-- Add index on frequent filter columns
CREATE INDEX CONCURRENTLY ON tasks (user_id, status);
```

### In-Memory Caching

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

### Goroutine Leaks

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

## Red Flags

- Optimization without profiling data
- N+1 query patterns in data fetching
- List endpoints without pagination
- No indexes on high-cardinality filter columns
- Goroutines started without a cancellation path
- Allocations inside hot loops (check with `-benchmem`)

## Reference

Before finishing a performance pass, read `references/performance-checklist.md` for a quick-scan checklist covering database, API, and common anti-patterns.

## Verification

- [ ] Before/after benchmark numbers exist (not just "feels faster")
- [ ] The specific bottleneck is identified and addressed
- [ ] Benchmark or load test added to guard the regression
- [ ] No N+1 queries in new data fetching code
- [ ] Existing tests still pass
