# CLAUDE.md

## What this repo is

Personal dotfiles for a Debian/Linux desktop.  
Everything tracked here ends up living at the same relative path under `~`.

## Installation

```sh
# Symlink all tracked files into $HOME
# (replaces existing files, no confirmation prompt)
./_link.sh

# print what would be linked, without touching the filesystem
DRY=1 ./_link.sh
```

## Lint and format

```sh
# Lint shell scripts (shellcheck)
./_lint.sh

# Format shell scripts in-place shfmt (via .local/bin/shellfmt)
./_fmt.sh
```

Both are driven by `.config/shellcheckrc`, which also lands at `$XDG_CONFIG_HOME/shellcheckrc` and serves as the global config. Shellcheck wants that file directly in `.config/`, not in a `shellcheck/` subdirectory.

There is no test suite.

## Architecture

### Shell config loading order

```
login shell:   .profile  →  sources each .profile.d/[0-9]*.sh in order
bash shell:    .bashrc   →  sources each .bashrc.d/[0-9]*.bash in order
```

Files are numbered to control load order. `.profile.d/` sets PATH and env exports (sh-compatible).
`.bashrc.d/` sets up the interactive shell: history, ssh-agent, tool config, etc.  
Most of it is bash-specific; the rest is portable but interactive-only.

### `.local/bin/` scripts

Standalone utilities, each a self-contained executable.  
Shebangs are either `#!/usr/bin/env sh` or `#!/usr/bin/env bash`.

For a new script, copy the preamble and helpers (`log`, dependency checks, cleanup traps) from an existing one.

## Shell completion

`.local/share/bash-completion/completions/_complete` is one generic completion function shared by every script that wants completion. Wire a script up by symlinking `_complete` under that script's own name, and teaching the script a hidden `--list-commands` flag that prints one `name<TAB>args` line per subcommand:

```sh
ln -s _complete .local/share/bash-completion/completions/<name>
```

The header of `_complete` documents the arg placeholders and what each one completes.

## Code style

- Shell: `set -eu` (sh) or `set -eu -o pipefail` (bash). Match whatever `shfmt` (via `.local/bin/shellfmt`) produces.
- Sourced-only shell files (no shebang, e.g. under `.local/share/bash-completion/completions/`) must have `# shellcheck shell=bash` or `# shellcheck shell=sh` as their first line; `_fmt.sh` detects them by it.
- Python: standard style; no external deps beyond stdlib unless unavoidable.
- Everything else (indent, charset, line endings, final newline, trailing whitespace) is in `.editorconfig`.
