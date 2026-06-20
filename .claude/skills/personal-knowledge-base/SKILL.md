---
name: personal-knowledge-base
description: Read and write the user's aikb Zettelkasten via mcp__aikb__* tools. TRIGGER before WebSearch/WebFetch on any open-ended topic (people, places, projects, past decisions, recurring topics) and whenever a task — including a code/infra task — surfaces a fact, concept, decision, or technique with value outside that task (vendor docs, API/rate limits, pricing, protocol behavior, library quirks). The fact being portable is what matters, not whether the task that produced it was code-local. SKIP only the lookup step when the thing being checked is the repo's own code/config (e.g. "what does this function do") — never skip the write-back step on that basis alone.
---

# Personal Knowledge Base (aikb)

## Overview

The user keeps a Zettelkasten — small, atomic notes that link to each other (backlinks included) and accumulate over time, reachable through the `aikb` MCP server: `mcp__aikb__note_search`, `note_read`, `note_list`, `note_backlinks`, `note_create`, `note_link`, `note_update`.

This is separate from this agent's own session/project memory (whatever memory system the harness provides for *this* agent's user/feedback/project context). aikb is the user's knowledge, durable across agents and tools, not this agent's notes about the user.

## Lookup — before researching

Before WebSearch/WebFetch on an open-ended topic, or answering a question whose answer might already be written down:

1. `mcp__aikb__note_search` for the topic.
2. If a note matches, `mcp__aikb__note_read` it and check `mcp__aikb__note_backlinks` for related notes before falling back to external search.

Skip *this lookup step* only when the thing being looked up is the repo's own code/config — there's no note for "what does `gateway.go:42` do." Everything else (a vendor's rate limits, a library's behavior, a person, a past decision) is fair game even if the surrounding task is a code task.

## Write-back — after learning something durable

A task being code/repo-local does not exempt facts learned *during* it. The question is whether the specific fact is portable, not whether the task was. Triggers, concretely:

- A fact fetched from external docs that would answer the same question on a different project (rate limits, pricing tiers, API behavior, protocol semantics, library quirks).
- A concept, technique, or gotcha worth recalling outside this codebase.
- A decision and its reasoning that matters beyond this one task.
- A fact about a person, place, or project.

When one of these comes up:

1. `mcp__aikb__note_search` to check whether a note on this already exists.
2. If yes, `mcp__aikb__note_update` it (fold in the new information, don't duplicate). If no, `mcp__aikb__note_create` a new atomic note — one idea per note.
3. `mcp__aikb__note_link` it to related existing notes where the connection is obvious.

## What doesn't belong here

- Task-scoped details (todo items, in-progress state) with no value once the task ends.
- This repo's own architecture, conventions, or file layout — that's `CLAUDE.md`/`AGENTS.md`/`docs/`, not aikb.
- A tradeoff or decision specific to *this* codebase that future engineers on *this* codebase need — that's an ADR in `docs/adrs/` via `documentation-and-adrs`, not aikb. (A fact is aikb material when it would still be true and useful on a different project; an ADR when it explains why *this* project is the way it is.)
