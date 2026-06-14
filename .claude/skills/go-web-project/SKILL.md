---
name: go-web-project
description: Create, scaffold, review, or modify Go web applications that use server-side rendering. Use for daemon-style Go services, net/http applications, html/template rendering, embedded templates and static assets, CLI configuration, XDG-compatible paths, Dockerfile generation, CI workflows, and simple maintainable web project structure.
---

Project is a Go web service. See `references/go-project-conventions.md` for module path convention, code style, project commands, pre-commit steps, and common dependencies.

## CLI Behavior

When the app exposes command-line behavior:

- POSIX-style flags: long form required, short form optional
- Always implement `--config <path>` and `--verbose`
- Write primary output to stdout; logs, warnings, and errors to stderr
- Exit `0` on success, `1` on runtime error, `2` on invalid usage/flags, `130` on SIGINT
- Graceful shutdown on SIGINT and SIGTERM
- Load config in order: hardcoded defaults → `/etc/{{project-name}}/config.yaml` → `~/.config/{{project-name}}/config.yaml` → env vars → flags

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
- `templates/LICENSE.txt`
- `templates/renovate.json`

Copy only the CI template that matches the project's hosting platform. Adapt the runner label if using self-hosted Forgejo.

## Third-Party Dependencies

- HTTP: `http.ServeMux`
- SQLite: `modernc.org/sqlite`

See `references/go-project-conventions.md` for common dependencies (JSON, YAML, UUID).

## Data Storage

Persist data either in JSON or CSV files or use SQLite (or PostgreSQL in extreme cases) if the additional complexity is justified.

## Containerize

Use a multi-stage Dockerfile: build stage produces a static binary (`CGO_ENABLED=0 go build -trimpath`), runtime stage is `scratch` with `ca-certificates.crt` copied in.

## References

- `references/go-project-conventions.md` — module path, code style, commands, common deps
