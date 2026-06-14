---
name: claude-dir-maintenance
description: Maintains the global .claude/ directory. Use to audit skill descriptions, check Handoffs wording, sync AGENTS.md decision tree and lifecycle, sync CLAUDE.md skills table, and regenerate README.md. Triggers on "maintain claude config", "audit skills", "update skill descriptions", or "clean up .claude".
---

# .claude Directory Maintenance

Keeps the global `~/.claude/` config directory correct, minimal, and navigable.

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

- Verify the section opens with: "Handoffs are suggestions — tell the user what comes next, do not invoke automatically."
- If that line is missing or different, add or correct it
- Verify downstream references describe what to suggest, not what to execute

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
2. Commands table: name + one-liner from each command's `description:` frontmatter
3. Command chains: for each command, what skills/agents it invokes and in what pattern (direct, fan-out, etc.)

Keep it minimal — this is a human reference, not instructions for the model.

## Verification

- `ls skills/` entries match AGENTS.md decision tree exactly (no gaps, no ghosts)
- `ls skills/` entries match CLAUDE.md skills table exactly
- `ls commands/` entries all appear in README.md
- Every `## Handoffs` section opens with the anti-auto-chain line
- All skill descriptions are action-verb led and ≤200 chars
- README.md reflects the current on-disk state

## Handoffs

This skill has no upstream or downstream.
