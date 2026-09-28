# shellcheck shell=bash

# ignore if non-interactive
case $- in
    *i*) ;;
    *) return ;;
esac

for file in "${HOME}/.bashrc.d/"[0-9]*; do
    if test -r "${file}"; then
        slow_start=${EPOCHREALTIME//[^0-9]/}
        # shellcheck disable=SC1090
        . "${file}"
        slow_took=$(((${EPOCHREALTIME//[^0-9]/} - slow_start) / 1000))
        if test "${slow_took}" -gt "500"; then
            echo >&2 "slow: ${file##*/} took ${slow_took}ms"
        fi
    fi
done
unset file slow_start slow_took
