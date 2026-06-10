---
name: go-cli-project
description: Create, scaffold, review, or modify Go CLI applications. Use for standalone Go binaries, flag or urfave/cli-based CLIs, goreleaser releases, USAGE.txt embedding, and CI workflows.
---

Project is a Go Module. Set the module path to match the Git platform:

- Codeberg: `codeberg.org/fhuebner/{{project-name}}`
- GitHub: `github.com/nothub/{{project-name}}`

## Interface design

- POSIX-style flags: long form required, short form optional
- Always implement `--config <path>` and `--verbose`
- Write primary output to stdout; logs, warnings, and errors to stderr
- Keep stdout pipe- and parse-friendly — no progress noise mixed in
- Exit `0` on success, `1` on runtime error, `2` on invalid usage/flags, `130` on SIGINT
- Graceful shutdown on SIGINT and SIGTERM
- Load config in order: hardcoded defaults → `/etc/{{project-name}}/config.yaml` → `~/.config/{{project-name}}/config.yaml` → env vars → flags
- Define the full interface in `USAGE.txt`; keep it in sync with every command, flag, and env var

## Code Style

- Return errors; do not panic in normal operation.
- Small functions with explicit names. No unexported global mutable state.
- Plain text output, scriptable.
- Every command exits with a non-zero code on failure.
- Extensively check errors for their types to handle errors gracefully.

## USAGE.txt

Embed `USAGE.txt` in the binary and use it as the source for `--help` output:

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
- `templates/.github/workflows/check.yaml` — GitHub Actions CI
- `templates/.gitattributes`
- `templates/.gitignore`
- `templates/.goreleaser.yaml`
- `templates/LICENSE.txt`
- `templates/README.md`
- `templates/renovate.json`

Copy only the CI template that matches the project's hosting platform.

Resolve these placeholders in `.goreleaser.yaml` before committing:

- `{{project-name}}` — binary name
- `{{module-path}}` — Go module path; adjust the `buildinfo` package path or remove ldflags if not embedding build info
- `{{git-host}}` / `{{git-owner}}` — e.g. `github.com` / `nothub` or `codeberg.org` / `fhuebner`

For Codeberg: add a `GITEA_TOKEN` secret with `write:repository` scope.
For GitHub: `GITHUB_TOKEN` is automatic.

## Goreleaser

Package goreleaser as a Go tool so it is version-pinned in `go.mod` and available in CI without a separate download step:

```sh
go get -tool github.com/goreleaser/goreleaser/v2@latest
```

Run locally and in CI with:

```sh
go tool goreleaser release --clean
go tool goreleaser build --clean --snapshot --single-target  # local snapshot
```


## Project Commands

Build: `go build -o {{project-name}} .`
Test: `go test -vet=all ./...`
Run: `go run .`
Format: `go fmt ./...`
Dependency cleanup: `go mod tidy`

## Pre-Commit

1. Format code
2. Dependency cleanup
3. Run tests

Report any command that could not be run and the reason for it.

## Third-party dependencies

- Flags/CLI: stdlib `flag` for simple tools; `github.com/urfave/cli/v3` when subcommands are needed
- JSON: `github.com/goccy/go-json`
- YAML: `github.com/goccy/go-yaml`
- UUID: `github.com/google/uuid`

Use the latest stable release of a library when pulling it into the project.

## Testing

Add unit tests when they provide useful confidence.
