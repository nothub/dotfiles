#!/usr/bin/env bash

set -eu
set -o pipefail

cd "$(dirname "$(realpath "$0")")"

find .bashrc.d/ -type f -exec .local/bin/shellfmt {} \;
find .profile.d/ -type f -exec .local/bin/shellfmt {} \;

readarray -d '' files < <(find .local/bin/ -type f -print0)
for f in "${files[@]}"; do
    if file "${f}" | grep "ASCII text executable" > /dev/null; then
        bang="$(head -n 1 "${f}")"
        if test "${bang}" = '#!/usr/bin/env sh' || test "${bang}" = '#!/usr/bin/env bash'; then
            .local/bin/shellfmt "${f}"
        fi
    fi
done
