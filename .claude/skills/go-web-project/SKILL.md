---
name: go-web-project
description: Scaffold and develop a new Go web application with SSR, SQLite/PostgreSQL, and Forgejo CI
---

Start new projects as Go Modules with path: `codeberg.org/fhuebner/{{project-name}}`

This project will:

- serve server-side rendered HTML content with stdlib go HTML templates
- make use of semantic HTML whenever feasible
- use classless css for styling
- do not use custom fonts, let the browser choose the font
- use minimalistic plain JavaScript if frontend logic is really required
- persist data either in JSON or CSV files or SQLite or PostgreSQL

Roughly follow these specs:

- POSIX
- XDG
- SemVer

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

- `github.com/goccy/go-json` for JSON handling
- `github.com/goccy/go-yaml` for YAML handling
- `http.ServeMux` for serving HTTP
- `github.com/elnormous/contenttype` to negotiate HTTP content-type
- `google/uuid` to generate UUIDs
- `modernc.org/sqlite` for SQLite
- `github.com/AmpyFin/yfinance-go` to fetch finance data
- `github.com/nothub/semver` to handle SemVer
- `github.com/yuin/goldmark` to handle Markdown

Use standard library and built-in tooling whenever possible for other stuff.

Use the latest stable release of a library when pulling it into the project.

## Testing

Add tests when they provide useful confidence.

## Configuration

Configuration should be done with:

- env vars
- YAML config files

## Containerize

Use Dockerfile template `templates/Dockerfile` to containerize.

The template Dockerfile uses a multi-stage build and copies ca certs to the runtime environment.

Extend the build (first) stage if additional build logic is required.

Extend the runtime (second) stage if changes to the `scratch` environment are needed.
