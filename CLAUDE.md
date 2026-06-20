# CLAUDE.md

## What this repo is

Personal dotfiles for a Debian/Linux desktop.  
Files are symlinked into `~` via `reclink`.  
Everything tracked here ends up living at the same relative path under `~`.

## Installation

```sh
# Symlink all tracked files into $HOME (replaces existing files, no confirmation prompt)
./_link.sh
```

`_link.sh` calls `.local/bin/reclink`, a Python 3 script that recursively symlinks source → target, skipping the files listed in the `--ignore` block (repo meta-files, `.idea/`, etc.).

## Lint and format

```sh
# Lint shell scripts (shellcheck)
./_lint.sh

# Format shell scripts in-place shfmt (via .local/bin/shellfmt)
./_fmt.sh
```

`_lint.sh` runs `shellcheck` on `.profile`, `.profile.d/`, `.bashrc`, and `.bashrc.d/`. `.shellcheckrc` disables SC2002 (useless cat) globally.

`_fmt.sh` runs `shfmt` (via the local `shellfmt` wrapper) on `.bashrc.d/`, `.profile.d/`, and all executables under `.local/bin/` with an `sh` or `bash` shebang. `shellfmt` calls `shfmt --write --simplify --indent 4 --binary-next-line --case-indent --space-redirects`.

There is no test suite.

## Architecture

### Shell config loading order

```
login shell:   .profile  →  sources each .profile.d/[0-9]*.sh in order
bash shell:    .bashrc   →  sources each .bashrc.d/[0-9]*.bash in order
```

Files are numbered to control load order. `.profile.d/` sets PATH and env exports (sh-compatible). `.bashrc.d/` sets history, SSH agent, tool config, aliases, functions, completions, and prompt (bash-specific).

### `.local/bin/` scripts

Standalone utilities, each a self-contained executable. Shebangs are either `#!/usr/bin/env sh`, `#!/usr/bin/env bash`, or `#!/usr/bin/env python3`. No shared libraries between them.

## Code style

- Shell: 4-space indent, `set -eu` (sh) or `set -eu -o pipefail` (bash), LF line endings. Match whatever `shfmt` (via `.local/bin/shellfmt`) produces.
- JSON/TOML/YAML: 2-space indent.
- Python: standard style; no external deps beyond stdlib unless unavoidable.
- All files: UTF-8, LF, trailing newline, no trailing whitespace (except `.md`).
