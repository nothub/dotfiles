# CLAUDE.md

## What this repo is

Personal dotfiles for a Debian/Linux desktop.  
Everything tracked here ends up living at the same relative path under `~`.

## Installation

```sh
# Symlink all tracked files into $HOME
# (replaces existing files, no confirmation prompt)
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

## Script snippets

Patterns for new `.local/bin/` scripts, kept from the removed `template` and `mkscript`.

Log to stderr, leave stdout for the actual output:

```bash
log() {
    echo >&2 "$*"
}
```

Cleanup on exit and on signals. `set -o errtrace` makes the `ERR` trap fire inside functions too:

```bash
finally() {
    trap - SIGINT SIGTERM ERR EXIT
    log "Bye ;)"
}
trap finally SIGINT SIGTERM ERR EXIT
```

Option parsing:

```bash
while getopts a:vh? opt; do
    case $opt in
        a) a="$OPTARG" ;;
        v) set -o xtrace ;;
        h | \? | *)
            usage
            exit
            ;;
    esac
done
shift $((OPTIND - 1))
```

Fall back to stdin when no args are given:

```bash
read_stdin() {
    if test -p /dev/stdin; then
        local line
        while IFS= read -r line; do
            echo "${line}"
        done
    fi
}

echo "${*:-$(read_stdin)}"
```

Fail early on missing tools:

```bash
check_dependency() {
    if ! command -v "$1" > /dev/null 2>&1; then
        log "Error: missing dependency: $1"
        exit 1
    fi
}
```

## Code style

- Shell: 4-space indent, `set -eu` (sh) or `set -eu -o pipefail` (bash), LF line endings. Match whatever `shfmt` (via `.local/bin/shellfmt`) produces.
- Sourced-only shell files (no shebang, e.g. under `.local/share/bash-completion/completions/`) must have `# shellcheck shell=bash` or `# shellcheck shell=sh` as their first line; `_fmt.sh` detects them by it.
- JSON/TOML/YAML: 2-space indent.
- Python: standard style; no external deps beyond stdlib unless unavoidable.
- All files: UTF-8, LF, trailing newline, no trailing whitespace (except `.md`).
