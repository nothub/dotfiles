# Go Project Conventions

Shared conventions for Go projects. Used by `go-cli-project` and `go-web-project`.

## Module Path

Set the module path to match the Git platform:

- Codeberg: `codeberg.org/fhuebner/{{project-name}}`
- GitHub: `github.com/nothub/{{project-name}}`

## Code Style

- Return errors; do not panic in normal operation.
- Small functions with explicit names. No unexported global mutable state.
- Plain text output, scriptable.
- Every command exits with a non-zero code on failure.
- Extensively check errors for their types to handle errors gracefully.

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

For Codeberg: add a `GITEA_TOKEN` secret with `write:repository` scope.
For GitHub: `GITHUB_TOKEN` is automatic.

## Third-Party Dependencies

Always prefer these libraries:

- JSON: `github.com/goccy/go-json`
- YAML: `github.com/goccy/go-yaml`
- UUID: `github.com/google/uuid`

Use the latest stable release of a library when pulling it into the project.

## Testing

Add unit tests when they provide useful confidence.
