---
name: go-web-project
description: Create or modify Go web applications using server-side rendering and Go HTML templates.
---

Project is a Go Module with path: `codeberg.org/fhuebner/{{project-name}}`

This project will provide a daemonized application serving web content.

## Specs

We roughly adhere to the following standards:

- POSIX
- XDG
- SemVer

### CLI Behavior

- Write data to stdout.
- Write logs to stderr.
- Read data from stdin.

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

## Code Style

- Return errors; do not panic in normal operation.
- Small functions with explicit names. No unexported global mutable state.
- Plain text output, scriptable.
- Every command exits with a non-zero code on failure.
- Extensively check errors for their types to handle errors gracefully.

Before commiting, always format the project with `go fmt ./...` to format all Go code and
`~/.local/bin/shellfmt {{path}}` to format a bash script.

## Web Design

- Prioritize server-side rendered HTML content with stdlib go HTML templates.
- Make use of semantic HTML whenever feasible.
- Use classless css for styling.
- Do not use custom fonts, let the browser choose the font.
- Use minimalistic plain JavaScript if frontend logic is really required.

## Project Layout

- `references/.gitignore`
- `references/README.md`
- `templates/.forgejo/workflows/check.yaml`
- `templates/Dockerfile`
- `templates/LICENSE.txt`

## Commands

Build: `go build -o {{project-name}} .`  
Build-Container: `docker build -t {{project-name}} .`  
Test: `go test -vet=all ./...`  
Run: `go run .`

## Third-party dependencies

Always prefer these libraries:

- HTTP: `http.ServeMux`
- JSON: `github.com/goccy/go-json`
- YAML: `github.com/goccy/go-yaml`
- UUID: `google/uuid`
- SQLite: `modernc.org/sqlite`

Use the latest stable release of a library when pulling it into the project.

## Testing

Add tests when they provide useful confidence.

Before commiting, `go test -vet=all ./...` must pass clean.

## Data storage

Persist data either in JSON or CSV files or use SQLite (or PostgreSQL in extreme cases) if the additional complexity is
justified.

## Containerize

Use Dockerfile template `templates/Dockerfile` to containerize.

The template Dockerfile uses a multi-stage build and copies ca certs to the runtime environment.

Extend the build (first) stage if additional build logic is required.

Extend the runtime (second) stage if changes to the `scratch` environment are needed.
