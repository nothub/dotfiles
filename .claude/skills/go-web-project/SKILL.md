---
name: go-web-project
description: Create, scaffold, review, or modify Go web applications that use server-side rendering. Use for daemon-style Go services, net/http applications, html/template rendering, embedded templates and static assets, CLI configuration, XDG-compatible paths, Dockerfile generation, CI workflows, and simple maintainable web project structure.
---

Project is a Go Module. Set the module path to match the Git platform:

- Codeberg: `codeberg.org/fhuebner/{{project-name}}`
- GitHub: `github.com/nothub/{{project-name}}`
- Self-hosted Forgejo: `{{forgejo-host}}/fhuebner/{{project-name}}`

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

## Static Assets

No CDN. Assets are served directly from the binary or disk.

- Embed templates, CSS, JS, and small static files in the binary with `//go:embed`
- Serve them via `http.FileServer(http.FS(embedded))` — no external host or CDN needed
- Large binary files (images, downloads) serve from disk to avoid inflating binary size
- Set `Cache-Control: max-age=31536000, immutable` on static assets
- Use content-hashed filenames (e.g. `app.a3f9c1.css`) for cache busting without stale-file risk

```go
//go:embed static/*
var staticFiles embed.FS

mux.Handle("/static/", http.FileServer(http.FS(staticFiles)))
```

## Project Layout

When creating a new project, copy required files from `templates/` into the project root.
Preserve relative paths. Replace `{{project-name}}` placeholders before writing files.
Do not leave unresolved placeholders in generated project files.

Required template files:

- `templates/.forgejo/workflows/check.yaml` — Forgejo/Codeberg CI (runner: `codeberg-small`)
- `templates/.github/workflows/check.yaml` — GitHub Actions CI (runner: `ubuntu-24.04`)
- `templates/.gitattributes`
- `templates/.gitignore`
- `templates/.goreleaser.yaml` — release automation (linux only)
- `templates/Dockerfile`
- `templates/LICENSE.txt`
- `templates/README.md`
- `templates/renovate.json`

Copy only the CI template that matches the project's hosting platform. Adapt the runner label if using self-hosted Forgejo.

The CI template includes a `release` job (goreleaser) that triggers on `v*` tags. Before using it, resolve these placeholders in `.goreleaser.yaml`:

- `{{project-name}}` — binary name
- `{{module-path}}` — Go module path (e.g. `github.com/nothub/{{project-name}}`); adjust the `buildinfo` package path to match your actual version vars, or remove the ldflags if you don't embed build info
- `{{git-host}}` / `{{git-owner}}` — e.g. `github.com` / `nothub` or `codeberg.org` / `fhuebner`

For Codeberg: add a `GITEA_TOKEN` secret with `write:repository` scope.
For GitHub: `GITHUB_TOKEN` is automatic.

## Project Commands

Build: `go build -o {{project-name}} .`  
Test: `go test -vet=all ./...`  
Run: `go run .`
Format: `go fmt ./...`
Dependency cleanup: `go mod tidy`

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
