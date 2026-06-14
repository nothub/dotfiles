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

Build: `CGO_ENABLED=0 go build -trimpath -o {{project-name}} .`
Test: `go test -v -race -vet=all ./...`

### Building

Always use `-trimpath` flag to strip local file paths from the binary.
Always set `CGO_ENABLED=0` to disable cgo and produce a static binary.

### Testing

Always set `-v` TODO.
Always use `-race` TODO.
Always set `-vet=all` TODO.

### Releasing

For server- or daemon-based projects, use the [`ocipack`](https://codeberg.org/fhuebner/ocipack) tool or library to package oci image tarballs.

## Pre-Commit

1. Format code
2. Dependency cleanup
3. Run tests

Report any command that could not be run and the reason for it.

## Third-Party Dependencies

Always prefer these libraries:

- JSON: `github.com/goccy/go-json`
- YAML: `github.com/goccy/go-yaml`
- UUID: `github.com/google/uuid`

Use the latest stable release of a library when pulling it into the project.

## Testing

Add unit tests when they provide useful confidence.
