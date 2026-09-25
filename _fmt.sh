#!/usr/bin/env bash

set -eu
set -o pipefail

cd "$(dirname "$(realpath "$0")")"

find .bashrc.d/ -type f -exec .local/bin/shellfmt {} \;
find .profile.d/ -type f -exec .local/bin/shellfmt {} \;

readarray -d '' files < <(find .local/bin/ .local/share/bash-completion/completions/ -type f -print0)
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
