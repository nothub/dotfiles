---
description: Conduct a five-axis code review — correctness, readability, architecture, security, performance
---

Invoke the code-review-and-quality skill.

Review the current changes (staged or recent commits) across all five axes:

1. **Correctness** — Does it match the spec? Edge cases handled? Tests adequate?
2. **Readability** — Clear names? Straightforward logic? Well-organized?
3. **Architecture** — Follows existing patterns? Clean boundaries? Right abstraction level?
4. **Security** — Input validated? Secrets safe? Auth checked? (Use security-and-hardening skill)
5. **Performance** — No N+1 queries? No unbounded ops? (Use performance-optimization skill)

Categorize findings as Critical, Important, or Suggestion.
Output a structured review with specific file:line references and fix recommendations.

**Qualifier:** use `$ARGUMENTS` as the qualifier slug (e.g. `/quality-review security`, `/quality-review user-auth`). If no argument is given, default to `review`.

**File:** check for an existing `docs/ai/*-{qualifier}.md` first — if one exists (e.g. mid feature chain), edit its `## Review` section in place: drop findings that are now resolved or outdated, keep what's still valid, add new ones — and bump `updated:`. Otherwise create `docs/ai/{today}-{qualifier}.md` (create the directory if it doesn't exist) with a frontmatter block (`created:`/`updated:` set to now) and a `## Review` section.
