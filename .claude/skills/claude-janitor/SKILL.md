---
name: claude-janitor
description: Maintain the global .claude/ directory. Audits skills, personas, Handoffs, commands, references, AGENTS.md, and CLAUDE.md. Use when asked to audit, clean up, or sync the .claude/ config.
---

# .claude Janitor

Keeps the global `.claude/` config directory correct, minimal, and idiomatic.

## Steps

### 0. Preparation

List all personas from `agents/`, commands from `commands/`, files from `references/`, and skills from `skills/`.

### 1. Audit skill descriptions

For each `skills/*/SKILL.md`:

- Verify `name:` frontmatter matches the directory name
- Read the `description:` frontmatter
- Check it would trigger loading when the user describes that task in plain language
- Good: specific, action-verb lead, ≤200 chars, no jargon
- Bad: vague ("use when you need X"), too broad, or unlikely to match real phrasing

Fix any descriptions that fail this check.

### 2. Audit personas

For each `agents/*.md` (excluding `README.md`):

- Verify `name:` frontmatter exists and matches the filename (without `.md`)
- Verify `description:` frontmatter exists, is action-verb led, and is ≤200 chars
- Fix any that fail this check

Verify `agents/README.md` table lists exactly the personas on disk — add missing rows, remove orphaned ones.

### 3. Audit Handoffs sections

For each `skills/*/SKILL.md` that contains `## Handoffs`:

- Verify the section contains only navigation labels: `**Upstream:**`, `**Downstream:**`, and/or `**Pair:**`
- Each label should describe what skills relate and why — not instruct the model to invoke them
- If any label contains imperative language ("invoke X", "run X next"), rewrite it as descriptive ("X continues from here")
- Verify any skill name cited in a label (`` `skill-name` `` pattern) has a corresponding `skills/<name>/` directory on disk; flag broken references for manual review

### 4. Audit commands

For each `commands/*.md`:

- Verify a non-empty `description:` frontmatter exists
- Verify any skill name referenced in the body (as `` `skill-name` ``) has a corresponding `skills/skill-name/` directory on disk
- Verify any persona name referenced in the body (as `subagent_type` value or equivalent) has a corresponding `agents/<name>.md` file on disk

Fix missing frontmatter; flag broken skill or persona references for manual review.

### 5. Audit references

- List all files under `references/`
- Verify each one is linked from at least one `skills/*/SKILL.md` or `commands/*.md`
- List all `references/X` links in skill files and command files; verify each file exists on disk

Remove orphaned reference files; flag broken links for manual review.

### 6. Sync AGENTS.md

**Decision tree:**
- List all directories under `skills/`
- Verify every skill appears in the Intent → Skill Mapping tree
- Verify every tree entry has a corresponding `skills/<name>/` directory
- Add missing entries; remove orphaned ones

**Lifecycle sequence:**
- Verify every skill listed in the Lifecycle Sequence exists as `skills/<name>/` on disk
- Remove any sequence entry whose skill directory is missing

### 7. Sync CLAUDE.md skills table

- List all directories under `skills/`
- Verify the table has exactly one row per skill
- Verify each one-liner matches the skill's actual purpose
- Add missing rows; remove orphaned rows

### 8. Regenerate README.md

Rewrite `.claude/README.md` with current state:

1. One-paragraph description of the `.claude/` directory
2. Commands table: name + one-liner from each command's `description:` frontmatter, ordered by real-world usage sequence
3. Command chains: for each orchestration command, what skills/agents it invokes and in what pattern (sequential, fan-out, etc.)

Keep it minimal — this is a human reference, not instructions for the model.

## Verification

- `ls skills/` entries match AGENTS.md decision tree exactly (no gaps, no ghosts)
- Every skill in the AGENTS.md lifecycle sequence exists on disk
- `ls skills/` entries match CLAUDE.md skills table exactly
- `ls commands/` entries all appear in README.md with non-empty `description:` frontmatter
- Every `references/` file is linked from at least one skill or command; every reference link in skills and commands resolves to a file on disk
- Every `## Handoffs` section contains only Upstream/Downstream/Pair labels (no imperative language)
- Every skill name cited in a Handoffs label resolves to a skill on disk
- All skill descriptions are action-verb led, ≤200 chars, and have `name:` matching the directory name
- All persona descriptions are action-verb led and ≤200 chars, with `name:` matching the filename
- `agents/README.md` table lists exactly the on-disk personas
- Every persona referenced by a command exists in `agents/`
- README.md reflects the current on-disk state

## Reference

See `references/orchestration-patterns.md` for the pattern catalog covering parallel fan-out, sequential chains, and other orchestration patterns used in this config.

## Handoffs

This skill has no upstream or downstream.
