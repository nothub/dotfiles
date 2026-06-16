---
description: Start spec-driven development — write a structured specification before writing code
---

Invoke the spec-driven-development skill.

Begin by understanding what the user wants to build. Ask clarifying questions about:
1. The objective and target users
2. Core features and acceptance criteria
3. Tech stack preferences and constraints
4. Known boundaries (what to always do, ask first about, and never do)

Then generate a structured spec covering all six core areas: objective, commands, project structure, code style, testing strategy, and boundaries.

**Qualifier:** use `$ARGUMENTS` as the qualifier slug (e.g. `/spec user-auth` → `spec-user-auth.md`). If no argument is given, derive a short kebab-case slug from the feature name once it becomes clear during the interview. Save the spec as `.ai/spec-{qualifier}.md` (create the directory if it doesn't exist) and confirm with the user before proceeding.
