---
name: go-cli-project
description: Create or modify Go CLI applications with a short-lived process runtime.
---

Project is a Go Module with path: `codeberg.org/fhuebner/{{project-name}}`

This project will provide a CLI application with a short-lived process runtime.

## Specs

We roughly adhere to the following standards:

- POSIX
- XDG
- SemVer

### CLI Behavior

- Write data to stdout.
- Write logs to stderr.
- Read data from stdin.

## Commands

These CLI commands must be implemented in every Go CLI application:
- `doctor` Check the application for common problems.
- `config [get|set]` Show the application configuration.

### Configuration

### Order

The config will be loaded from these sources in order:

1. Hardcoded defaults
2. YAML files
    - `/etc/{{project-name}}/config.yaml`
    - `~/.config/{{project-name}}/config.yaml`
3. Environment variables
4. Flags

### Flags

Make sure these flags are always implemented:

- `--help`
- `--version`
- `--verbose`
- `--config {{path}}`

## Signals

Do a graceful shutdown on `SIGINT` or `SIGTERM` signals.
Reload config on `SIGHUP`.

## Code Style

- Return errors; do not panic in normal operation.
- Small functions with explicit names. No unexported global mutable state.
- Plain text output, scriptable.
- Every command exits with a non-zero code on failure.
- Extensively check errors for their types to handle errors gracefully.

Before commiting, always format the project with `go fmt ./...` to format all Go code and
`~/.local/bin/shellfmt {{path}}` to format a bash script.

## Project Layout

- `references/.gitignore`
- `references/README.md`
- `templates/.forgejo/workflows/check.yaml`
- `templates/LICENSE.txt`

## Commands

Build: `go build -o {{project-name}} .`  
Test: `go test -vet=all ./...`  
Run: `go run .`

## Third-party dependencies

Always prefer these libraries:

- JSON: `github.com/goccy/go-json`
- YAML: `github.com/goccy/go-yaml`
- UUID: `google/uuid`
- SQLite: `modernc.org/sqlite`

Use the latest stable release of a library when pulling it into the project.

## Testing

Add unit tests when they provide useful confidence.
