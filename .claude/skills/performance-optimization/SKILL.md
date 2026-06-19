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

N+1 queries, unbounded data fetching, missing indexes, in-memory caching, goroutine leaks, and HTTP response caching all have a standard fix shape. Read `references/performance-code-patterns.md` for the Go before/after for each.

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
