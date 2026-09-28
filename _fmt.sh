#!/usr/bin/env bash

set -eu
set -o pipefail

cd "$(dirname "$(realpath "$0")")"

# a machine dir mirrors the repo root, so it is searched at the same relative
# paths. every machine is formatted, not just this one, or a script would only
# be touched on the host that happens to run this
roots=(".")
for dir in machines/*/; do
    if test -d "${dir}"; then
        roots+=("${dir%/}")
    fi
done

# not every root holds every path, so a missing one is skipped rather than
# left for find to complain about
in_roots() {
    local root
    for root in "${roots[@]}"; do
        if test -e "${root}/$1"; then
            find "${root}/$1" -type f -print0
        fi
    done
}

readarray -d '' fragments < <(in_roots ".bashrc.d"; in_roots ".profile.d")
for f in "${fragments[@]}"; do
    .local/bin/shellfmt "${f}"
done

readarray -d '' files < <(in_roots ".local/bin"; in_roots ".local/share/bash-completion/completions")
for f in "${files[@]}"; do
    if file "${f}" | grep "ASCII text" > /dev/null; then
        bang="$(head -n 1 "${f}")"
        case "${bang}" in
            '#!/usr/bin/env sh' | '#!/usr/bin/env bash' | '# shellcheck shell=bash')
                .local/bin/shellfmt "${f}"
                ;;
        esac
    fi
done
