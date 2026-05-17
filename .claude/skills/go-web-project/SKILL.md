---
name: go-web-project
description: Create, scaffold, review, or modify Go web applications that use server-side rendering. Use for daemon-style Go services, net/http applications, html/template rendering, embedded templates and static assets, CLI configuration, XDG-compatible paths, Dockerfile generation, CI workflows, and simple maintainable web project structure.
---

Project is a Go Module with path: `codeberg.org/fhuebner/{{project-name}}`

This project will provide a daemonized app serving web content.

## CLI behavior

When the web app exposes command-line behavior, follow the `cli-app-designer` skill for:

- commands and subcommands
- flags and options
- stdin/stdout/stderr behavior
- configuration loading
- environment variables
- usage/help output
- process signals
- exit codes

Use this skill (`go-web-project`) for the Go- and domain-specific implementation:

- project layout
- `net/http`
- `html/template`
- embedded assets
- configuration structs
- server startup
- graceful shutdown
- Tests
- Dockerfile
- CI workflows

## Code Style

- Return errors; do not panic in normal operation.
- Small functions with explicit names. No unexported global mutable state.
- Plain text output, scriptable.
- Every command exits with a non-zero code on failure.
- Extensively check errors for their types to handle errors gracefully.

## Web Design

- Prioritize server-side rendered HTML content with stdlib go HTML templates.
- Make use of semantic HTML whenever feasible.
- Use classless css for styling.
- Do not use custom fonts, let the browser choose the font.
- Use minimalistic plain JavaScript if frontend logic is really required.

## Project Layout

All projects should have these mandatory files:

- `references/.gitignore`
- `references/README.md`
- `templates/.forgejo/workflows/check.yaml`
- `templates/Dockerfile`
- `templates/LICENSE.txt`
- `references/renovate.json`

## Project Commands

Build Go: `go build -o {{project-name}} .`  
Build Container: `docker build -t {{project-name}} .`  
Test Go: `go test -vet=all ./...`  
Run Go: `go run .`
Format Go: `go fmt ./...`
Dependency cleanup Go: `go mod tidy`

## Pre-Commit

Run these commands before committing:

1. Format code
2. Dependency cleanup
3. Run tests

Report any command that could not be run and the reason for it.

## Third-party dependencies

Always prefer these libraries:

- HTTP: `http.ServeMux`
- JSON: `github.com/goccy/go-json`
- YAML: `github.com/goccy/go-yaml`
- UUID: `google/uuid`
- SQLite: `modernc.org/sqlite`

Use the latest stable release of a library when pulling it into the project.

## Testing

Add unit tests when they provide useful confidence.

## Data storage

Persist data either in JSON or CSV files or use SQLite (or PostgreSQL in extreme cases) if the additional complexity is
justified.

## Containerize

Use Dockerfile template `templates/Dockerfile` to containerize.

The template Dockerfile uses a multi-stage build and copies ca certs to the runtime environment.

Extend the build (first) stage if additional build logic is required.

Extend the runtime (second) stage if changes to the `scratch` environment are needed.
