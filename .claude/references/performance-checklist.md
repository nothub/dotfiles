# Performance Checklist

Quick reference checklist for web application performance. Use alongside the `performance-optimization` skill.

## Frontend Checklist

### Images
- [ ] Images use modern formats (WebP, AVIF)
- [ ] Images are responsively sized (`srcset` and `sizes`)
- [ ] Images have explicit `width` and `height` attributes (prevents layout shift)
- [ ] Below-the-fold images use `loading="lazy"` and `decoding="async"`
- [ ] Hero/above-the-fold images use `fetchpriority="high"` and no lazy loading

### Network
- [ ] Static assets cached with long `max-age` + content hashing
- [ ] API responses cached where appropriate (`Cache-Control`)
- [ ] HTTP/2 or HTTP/3 enabled
- [ ] No unnecessary redirects

### CSS & Rendering
- [ ] Critical CSS inlined or preloaded
- [ ] No render-blocking CSS for non-critical styles
- [ ] Animations use `transform` and `opacity` (GPU-accelerated)
- [ ] No forced synchronous layouts (batch DOM reads before writes)
- [ ] Off-screen sections use `content-visibility: auto` with `contain-intrinsic-size`

## Backend Checklist

### Database
- [ ] No N+1 query patterns (use eager loading / joins)
- [ ] Queries have appropriate indexes
- [ ] List endpoints paginated (never `SELECT * FROM table`)
- [ ] Connection pooling configured
- [ ] Slow query logging enabled

### API
- [ ] Response times < 200ms (p95)
- [ ] No synchronous heavy computation in request handlers
- [ ] Bulk operations instead of loops of individual calls
- [ ] Response compression (gzip/brotli)
- [ ] Appropriate caching (in-memory, Redis, CDN)

## Measurement

```bash
# Page performance audit
npx lighthouse https://localhost:3000 --output json --output-path ./report.json
```

## Common Anti-Patterns

| Anti-Pattern | Impact | Fix |
|---|---|---|
| N+1 queries | Linear DB load growth | Use joins or batch loading |
| Unbounded queries | Memory exhaustion, timeouts | Always paginate, add LIMIT |
| Missing indexes | Slow reads as data grows | Add indexes for filtered/sorted columns |
| Unoptimized images | Slow page load, wasted bandwidth | Use WebP, responsive sizes, lazy load |
| Layout thrashing | Jank, dropped frames | Batch DOM reads, then batch writes |
| Memory leaks | Growing memory, eventual crash | Clean up event listeners and intervals |
