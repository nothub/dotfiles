#!/usr/bin/env bash

set -eu
set -o pipefail

cd "$(dirname "$(realpath "$0")")"

# repo meta files, everything else is linked into $HOME at the same relative path
ignore=(
    ".git"
    ".gitattributes"
    ".gitignore"
    ".idea"
    ".vscode"
    "_fmt.sh"
    "_link.sh"
    "_lint.sh"
    "AGENTS.md"
    "CLAUDE.md"
    "README.md"
    "renovate.json"
)

log() {
    echo >&2 "$*"
}

# tracked files can be symlinks themselves (the bash-completion aliases), so
# those are linked as they are instead of being followed
while IFS= read -r -d '' src; do
    rel="${src#./}"

    for i in "${ignore[@]}"; do
        if test "${rel}" = "${i}" || test "${rel#"${i}"/}" != "${rel}"; then
            continue 2
        fi
    done

    target="${HOME}/${rel}"
    source="${PWD}/${rel}"

    # already linked, nothing to report
    if test -L "${target}" && test "$(readlink "${target}")" = "${source}"; then
        continue
    fi

    # ln would place the link inside it instead of replacing it
    if test -d "${target}" && ! test -L "${target}"; then
        log "skipping, target is a directory: ${target}"
        continue
    fi

    log "linking: ${rel}"
    if test -z "${DRY:-}"; then
        mkdir -p "$(dirname "${target}")"
        ln -sfn "${source}" "${target}"
    fi
done < <(find . \( -type f -o -type l \) -print0)
