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

# a link into this repo whose target is gone was created by an earlier run for
# a file that no longer exists, which makes it ours to remove. no bookkeeping
# needed, the link itself says where it came from
while IFS= read -r dir; do
    test -d "${HOME}/${dir}" || continue
    while IFS= read -r link; do
        case "$(readlink "${link}")" in
            "${PWD}/"*) ;;
            *) continue ;;
        esac
        test -e "${link}" && continue
        log "removing stale link: ${link#"${HOME}"/}"
        if test -z "${DRY:-}"; then
            rm -- "${link}"
        fi
    done < <(find "${HOME}/${dir}" -maxdepth 1 -type l)
done < <(find . \( -type f -o -type l \) -printf '%h\n' | sed 's|^\./||' | sort -u | grep -v '^\.git$\|^\.git/')
