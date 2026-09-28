# CLAUDE.md

## What this repo is

Personal dotfiles for a Debian/Linux desktop.  
Most stuff tracked here ends up living at the same relative path under `~`.

## Installation

```sh
# Symlink all tracked files into $HOME
# (replaces existing files, no confirmation prompt)
./_link.sh

# print what would be linked, without touching the filesystem
DRY=1 ./_link.sh
```

## Architecture

### Shell config

1. Login shell (`.profile`) sources `.profile.d/`  
   (PATH, env exports, etc.)
2. Interactive shell (`.bashrc`) sources `.bashrc.d/`  
   (history, tool config, etc.)

### `.local/bin/` scripts

Standalone utilities, each a self-contained executable.  
Only text-files (with `+x` and a shebang) allowed, no binary blobs.

For a new script, copy the required helpers from an existing one.

#### Completion

`.local/share/bash-completion/completions/_complete` is one generic helper shared by every script that has completion.  
Link `_complete` under that script name and add `--list-commands` to print one `name<TAB>args` line per subcommand.  
The header of `_complete` documents the arg placeholders and what each one completes.
Ask the user before adding any new placeholders.

## Development

### Pre-Commit

Lint: `./_lint.sh`  
Format: `./_fmt.sh`  
There is no test suite.

### Code style

- Shell:
  - `set -eu` (sh) or `set -eu -o pipefail` (bash).
  - Match whatever `./_fmt.sh` / `.local/bin/shellfmt` produces.
  - Use `test` instead of `[[` or `[`.
- Also respect `.editorconfig`

Sourced-only shell files (no shebang, e.g. completion script) must have `# shellcheck shell=bash`
or `# shellcheck shell=sh` as the first line; `_fmt.sh` detects them by it.
