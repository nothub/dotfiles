---
name: claude-janitor
description: Maintains the global .claude/ directory. Audits skill descriptions, checks Handoffs sections are clean navigation docs, syncs AGENTS.md decision tree, syncs CLAUDE.md skills table, and regenerates README.md. Triggers on "maintain claude config", "audit skills", "update skill descriptions", or "clean up .claude".
---

# .claude Janitor

Keeps the global `.claude/` config directory correct, minimal, and idiomatic.

## Steps

### 1. Audit skill descriptions

For each `skills/*/SKILL.md`:

- Read the `description:` frontmatter
- Check it would trigger loading when the user describes that task in plain language
- Good: specific, action-verb lead, ≤200 chars, no jargon
- Bad: vague ("use when you need X"), too broad, or unlikely to match real phrasing

Fix any descriptions that fail this check.

### 2. Audit Handoffs sections

For each `skills/*/SKILL.md` that contains `## Handoffs`:

- Verify the section contains only navigation labels: `**Upstream:**`, `**Downstream:**`, and/or `**Pair:**`
- Each label should describe what skills relate and why — not instruct the model to invoke them
- If any label contains imperative language ("invoke X", "run X next"), rewrite it as descriptive ("X continues from here")

### 3. Sync AGENTS.md

- List all directories under `skills/`
- Verify every skill appears in the Intent → Skill Mapping tree
- Verify every tree entry has a corresponding `skills/<name>/` directory
- Verify every skill in the Lifecycle Sequence exists on disk
- Add missing entries; remove orphaned ones

### 4. Sync CLAUDE.md skills table

- List all directories under `skills/`
- Verify the table has exactly one row per skill
- Verify each one-liner matches the skill's actual purpose
- Add missing rows; remove orphaned rows

### 5. Regenerate README.md

Rewrite `.claude/README.md` with current state:

1. One-paragraph description of the `.claude/` directory
2. Commands table: name + one-liner from each command's `description:` frontmatter, ordered by real-world usage sequence
3. Command chains: for each orchestration command, what skills/agents it invokes and in what pattern (sequential, fan-out, etc.)

Keep it minimal — this is a human reference, not instructions for the model.

## Verification

- `ls skills/` entries match AGENTS.md decision tree exactly (no gaps, no ghosts)
- `ls skills/` entries match CLAUDE.md skills table exactly
- `ls commands/` entries all appear in README.md
- Every `## Handoffs` section contains only Upstream/Downstream/Pair labels (no imperative language)
- All skill descriptions are action-verb led and ≤200 chars
- README.md reflects the current on-disk state

## Handoffs

This skill has no upstream or downstream.
