---
name: claude-janitor
description: Maintain the global .claude/ directory. Audits skills, personas, Handoffs, commands, references, AGENTS.md, and CLAUDE.md. Use when asked to audit, clean up, or sync the .claude/ config.
---

# .claude Janitor

Keeps the global `.claude/` config directory correct, minimal, and idiomatic.

## Steps

### 1. Preparation

List all personas from `agents/`, commands from `commands/`, files from `references/`, and skills from `skills/`.

### 2. Audit skill descriptions

For each `skills/*/SKILL.md`:

- Verify `name:` frontmatter matches the directory name
- Read the `description:` frontmatter
- Check it would trigger loading when the user describes that task in plain language
- Good: specific, action-verb lead, ≤200 chars, no jargon
- Bad: vague ("use when you need X"), too broad, or unlikely to match real phrasing

Fix any descriptions that fail this check.

### 3. Audit personas

For each `agents/*.md` (excluding `README.md`):

- Verify `name:` frontmatter exists and matches the filename (without `.md`)
- Verify `description:` frontmatter exists, is action-verb led, and is ≤200 chars
- Fix any that fail this check

Verify `agents/README.md` table lists exactly the personas on disk — add missing rows, remove orphaned ones.

### 4. Audit Handoffs sections

For each `skills/*/SKILL.md` that contains `## Handoffs`:

- Verify the section contains only navigation labels: `**Upstream:**`, `**Downstream:**`, and/or `**Pair:**`
- Each label should describe what skills relate and why — not instruct the model to invoke them
- If any label contains imperative language ("invoke X", "run X next"), rewrite it as descriptive ("X continues from here")
- Verify any skill name cited in a label (`` `skill-name` `` pattern) has a corresponding `skills/<name>/` directory on disk; flag broken references for manual review

### 5. Audit commands

For each `commands/*.md`:

- Verify a non-empty `description:` frontmatter exists
- Verify any skill name referenced in the body (as `` `skill-name` ``) has a corresponding `skills/skill-name/` directory on disk
- Verify any persona name referenced in the body (as `subagent_type` value or equivalent) has a corresponding `agents/<name>.md` file on disk

Fix missing frontmatter; flag broken skill or persona references for manual review.

### 6. Audit references

- List all files under `references/`
- Verify each one is linked from at least one of: `skills/*/SKILL.md`, `commands/*.md`, `AGENTS.md`, `CLAUDE.md`, or `README.md`
- List all `references/X` links in those files; verify each file exists on disk

Flag orphaned reference files and broken links for manual review — do not delete files automatically.

### 7. Audit routing coverage in skill descriptions

Routing is distributed: each skill's `description:` frontmatter must be self-sufficient — an agent reading only that line should know when to invoke the skill. There is no central routing flowchart; this audit is how it stays consistent.

For each `skills/*/SKILL.md`:

- Does the description answer "when would I reach for this?" in plain language?
- Does it name the triggering intent, not just what the skill does?
- If the skill has siblings (sub-skills invoked from within a parent workflow), does the parent's description mention them?

Key relationships to verify:
- `incremental-implementation` description lists its specialised sub-skills (UI → `frontend-ui-engineering`, API → `api-and-interface-design`, shell → `bash-script`, high stakes → `doubt-driven-development`)
- `code-review-and-quality` description mentions sub-skills for complex (`code-simplification`), security (`security-and-hardening`), and performance (`performance-optimization`) findings
- `spec-driven-development` is the entry point for any new project or feature (not `incremental-implementation` directly)
- `interview-me` is the entry point when the request is underspecified

Fix any description that fails this check.

### 8. Sync CLAUDE.md skills table

- List all directories under `skills/`
- Verify the table has exactly one row per skill
- Verify each one-liner matches the skill's actual purpose
- Add missing rows; remove orphaned rows

### 9. Regenerate README.md

Rewrite `.claude/README.md` with current state:

1. One-paragraph description of the `.claude/` directory
2. Commands table: name + one-liner from each command's `description:` frontmatter, ordered by real-world usage sequence
3. Command chains: for each orchestration command, what skills/agents it invokes and in what pattern (sequential, fan-out, etc.)

Keep it minimal — this is a human reference, not instructions for the model.

## Verification

- Every skill's `description:` frontmatter answers "when would I reach for this?" and names any sibling sub-skills
- `ls skills/` entries match CLAUDE.md skills table exactly
- `ls commands/` entries all appear in README.md with non-empty `description:` frontmatter
- Every `references/` file is linked from at least one of: `skills/*/SKILL.md`, `commands/*.md`, `AGENTS.md`, `CLAUDE.md`, or `README.md`; every reference link in those files resolves to a file on disk
- Every `## Handoffs` section contains only Upstream/Downstream/Pair labels (no imperative language)
- Every skill name cited in a Handoffs label resolves to a skill on disk
- All skill descriptions are action-verb led, ≤200 chars, and have `name:` matching the directory name
- All persona descriptions are action-verb led and ≤200 chars, with `name:` matching the filename
- `agents/README.md` table lists exactly the on-disk personas
- Every persona referenced by a command exists in `agents/`
- README.md reflects the current on-disk state

## Reference

See `references/orchestration-patterns.md` for the pattern catalog covering parallel fan-out, sequential chains, and other orchestration patterns used in this config.
