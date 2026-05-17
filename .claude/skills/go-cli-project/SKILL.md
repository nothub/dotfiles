---
name: go-cli-project
description: Scaffold and develop a new Go CLI application with POSIX/XDG conventions and Forgejo CI
---

Start new projects as Go Modules with path: `codeberg.org/fhuebner/{{project-name}}`

This project will:

- create a CLI application with a short-lived process runtime
- persist data either in JSON or CSV files or SQLite or PostgreSQL

Roughly follow these specs:

- POSIX
- XDG
- SemVer

## Layout

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

- `github.com/goccy/go-json` for JSON handling
- `github.com/goccy/go-yaml` for YAML handling
- `google/uuid` to generate UUIDs
- `modernc.org/sqlite` for SQLite
- `github.com/AmpyFin/yfinance-go` to fetch finance data
- `github.com/nothub/semver` to handle SemVer
- `github.com/yuin/goldmark` to handle Markdown
- `github.com/hajimehoshi/ebiten` for game related GUI development
- `github.com/gen2brain/raylib-go/raylib` for non-game related GUI development

Use standard library and built-in tooling whenever possible for other stuff.

Use the latest stable release of a library when pulling it into the project.

## Testing

Add tests when they provide useful confidence.

## Configuration

Configuration should be done with:

- flags
- YAML files
