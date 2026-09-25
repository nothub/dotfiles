#!/usr/bin/env bash

set -eu
set -o pipefail

cd "$(dirname "$(realpath "$0")")"

rcfile=".config/shellcheckrc"

# note: `find -exec ... \;` does not propagate the exit status of the command,
# so collect the files first and hand them to shellcheck in one go
readarray -d '' profile_files < <(find ".profile.d" -type f -print0)
shellcheck --rcfile="${rcfile}" --shell sh ".profile" "${profile_files[@]}"

readarray -d '' bashrc_files < <(find ".bashrc.d" -type f -print0)
shellcheck --rcfile="${rcfile}" --shell bash ".bashrc" "${bashrc_files[@]}"

shellcheck --rcfile="${rcfile}" --shell bash "_fmt.sh" "_link.sh" "_lint.sh"

# sourced-only files carry a `# shellcheck shell=` directive, so no --shell here
readarray -d '' completions < <(find ".local/share/bash-completion/completions" -type f -print0)
shellcheck --rcfile="${rcfile}" "${completions[@]}"

# the dialect comes from the shebang, so skip anything that is not sh or bash
readarray -d '' files < <(find ".local/bin" -type f -print0)
for f in "${files[@]}"; do
    case "$(head -n 1 "${f}")" in
        '#!/usr/bin/env sh') shellcheck --rcfile="${rcfile}" --shell sh "${f}" ;;
        '#!/usr/bin/env bash') shellcheck --rcfile="${rcfile}" --shell bash "${f}" ;;
    esac
done

# every completion link is named after the script it completes, so a link
# without a matching script means the script was removed and the link was not
stale=0
for link in ".local/share/bash-completion/completions/"*; do
    test -L "${link}" || continue
    name="$(basename "${link}")"
    if ! test -e ".local/bin/${name}"; then
        echo >&2 "stale completion link: ${link} (no .local/bin/${name})"
        stale=1
    fi
done
test "${stale}" -eq 0
