#!/usr/bin/env bash

set -eu
set -o pipefail

cd "$(dirname "$(realpath "$0")")"

rcfile=".config/shellcheckrc"

# a machine dir mirrors the repo root, so it is searched at the same relative
# paths. every machine is linted, not just this one, or a script would only be
# checked on the host that happens to run this
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

# note: `find -exec ... \;` does not propagate the exit status of the command,
# so collect the files first and hand them to shellcheck in one go
readarray -d '' profile_files < <(in_roots ".profile"; in_roots ".profile.d")
shellcheck --rcfile="${rcfile}" --shell sh "${profile_files[@]}"

readarray -d '' bashrc_files < <(in_roots ".bashrc"; in_roots ".bashrc.d")
shellcheck --rcfile="${rcfile}" --shell bash "${bashrc_files[@]}"

shellcheck --rcfile="${rcfile}" --shell bash "_fmt.sh" "_link.sh" "_lint.sh"

# sourced-only files carry a `# shellcheck shell=` directive, so no --shell here
readarray -d '' completions < <(in_roots ".local/share/bash-completion/completions")
shellcheck --rcfile="${rcfile}" "${completions[@]}"

# the dialect comes from the shebang, so skip anything that is not sh or bash
readarray -d '' files < <(in_roots ".local/bin")
for f in "${files[@]}"; do
    case "$(head -n 1 "${f}")" in
        '#!/usr/bin/env sh') shellcheck --rcfile="${rcfile}" --shell sh "${f}" ;;
        '#!/usr/bin/env bash') shellcheck --rcfile="${rcfile}" --shell bash "${f}" ;;
    esac
done

# every completion link is named after the script it completes, so a link
# without a matching script means the script was removed and the link was not.
# a machine completion may point at a shared script, so both roots count
stale=0
for root in "${roots[@]}"; do
    for link in "${root}/.local/share/bash-completion/completions/"*; do
        test -L "${link}" || continue
        name="$(basename "${link}")"
        if ! test -e "${root}/.local/bin/${name}" && ! test -e ".local/bin/${name}"; then
            echo >&2 "stale completion link: ${link} (no .local/bin/${name})"
            stale=1
        fi
    done
done
test "${stale}" -eq 0
