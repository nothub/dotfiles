---
name: go-cli-project
description: Create, scaffold, review, or modify Go CLI applications. Use for standalone Go binaries, flag or cobra-based CLIs, goreleaser releases, devbox dev environments, USAGE.txt embedding, CI workflows, and simple maintainable CLI project structure. Pair with cli-app-designer for interface design.
---

Project is a Go Module. Set the module path to match the Git platform:

- Codeberg: `codeberg.org/fhuebner/{{project-name}}`
- GitHub: `github.com/nothub/{{project-name}}`
- Self-hosted Forgejo: `{{forgejo-host}}/fhuebner/{{project-name}}`

## Interface design

Follow the `cli-app-designer` skill for commands, flags, stdin/stdout/stderr, signals, exit codes, XDG config, and USAGE.txt.

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

When creating a new project, copy required files from `../go-web-project/templates/` into the project root.
Preserve relative paths. Replace `{{project-name}}` placeholders before writing files.
Do not leave unresolved placeholders in generated project files.

Required template files (no Dockerfile — CLI tools ship as binaries, not containers):

- `../go-web-project/templates/.forgejo/workflows/check.yaml` — Forgejo/Codeberg CI
- `../go-web-project/templates/.github/workflows/check.yaml` — GitHub Actions CI
- `../go-web-project/templates/.gitattributes`
- `../go-web-project/templates/.gitignore`
- `../go-web-project/templates/.goreleaser.yaml`
- `../go-web-project/templates/LICENSE.txt`
- `../go-web-project/templates/README.md`
- `../go-web-project/templates/renovate.json`

Copy only the CI template that matches the project's hosting platform.

Resolve these placeholders in `.goreleaser.yaml` before committing:

- `{{project-name}}` — binary name
- `{{module-path}}` — Go module path; adjust the `buildinfo` package path or remove ldflags if not embedding build info
- `{{git-host}}` / `{{git-owner}}` — e.g. `github.com` / `nothub` or `codeberg.org` / `fhuebner`

For Codeberg: add a `GITEA_TOKEN` secret with `write:repository` scope.
For GitHub: `GITHUB_TOKEN` is automatic.

## Dev Environment

Create a `devbox.json` at the project root. Follow the `devbox-tool` skill. Minimum packages: `go` and `upx` (needed by goreleaser). Define `test` and `build` scripts:

```json
{
  "packages": ["go@<pin>", "upx@<pin>"],
  "shell": {
    "scripts": {
      "test": ["go test -v -vet=all ./..."],
      "build": ["go build -o {{project-name}} ."]
    }
  }
}
```

Pin all versions. Run `devbox search <pkg> --show-all` to find the latest stable.

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

- Flags/CLI: stdlib `flag` for simple tools; `github.com/spf13/cobra` when subcommands are needed
- JSON: `github.com/goccy/go-json`
- YAML: `github.com/goccy/go-yaml`
- UUID: `github.com/google/uuid`

Use the latest stable release of a library when pulling it into the project.

## Testing

Add unit tests when they provide useful confidence.
