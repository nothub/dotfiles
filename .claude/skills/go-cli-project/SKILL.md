---
name: go-cli-project
description: Create, scaffold, review, or modify Go CLI applications. Use for standalone Go binaries, flag or urfave/cli-based CLIs, USAGE.txt embedding, and CI workflows.
---

Project is a Go CLI binary. Read `references/go-project-conventions.md` first for module path convention, code style, project commands, pre-commit steps, and common dependencies.

## Interface Design

- POSIX-style flags: long form required, short form optional
- Always implement `--config <path>` and `--verbose`
- `help` and `version` are subcommands, not flags — never define `--help`/`-h` or `--version`/`-V`
- Write primary output to stdout; logs, warnings, and errors to stderr
- Keep stdout pipe- and parse-friendly — no progress noise mixed in
- Exit `0` on success, `1` on runtime error, `2` on invalid usage/flags, `130` on SIGINT
- Graceful shutdown on SIGINT and SIGTERM
- Load config in order: hardcoded defaults → `/etc/{{project-name}}/config.yaml` → `~/.config/{{project-name}}/config.yaml` → env vars → flags
- Define the full interface in `USAGE.txt`; keep it in sync with every command, flag, and env var

## USAGE.txt

Embed `USAGE.txt` in the binary and use it as the source for `help` command output:

```go
//go:embed USAGE.txt
var usage string
```

## Project Layout

When creating a new project, copy required files from `templates/` into the project root.
Preserve relative paths. Replace `{{project-name}}` placeholders before writing files.
Do not leave unresolved placeholders in generated project files.

Required template files (no Dockerfile — CLI tools ship as binaries, not containers):

- `templates/.forgejo/workflows/check.yaml` — Forgejo/Codeberg CI
- `templates/.gitattributes`
- `templates/.gitignore`
- `templates/LICENSE.txt`
- `templates/renovate.json`

Copy only the CI template that matches the project's hosting platform.

## Third-Party Dependencies

- Flags/CLI: stdlib `flag` for simple tools; `github.com/urfave/cli/v3` when subcommands are needed
  - When using urfave/cli/v3: set `HideHelp: true` and `HideVersion: true` on the `cli.App` to suppress the built-in `--help`/`-h` and `--version`/`-V` flags; implement `help` and `version` as explicit `cli.Command` entries instead

When picking a dependency beyond the ones above, read `references/go-project-conventions.md` for common choices (JSON, YAML, UUID).

## References

- `references/go-project-conventions.md` — read first, applies project-wide: module path, code style, commands, common deps
- `references/cli-usability-checklist.md` — read before finalizing the interface: exit codes, output streams, signal handling, --json, scriptability
- `references/testing-patterns.md` — read when writing tests: table-driven tests, CLI output testing, fuzz testing, benchmarks
