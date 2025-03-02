# shellcheck shell=bash

# ignore if non-interactive
case $- in
    *i*) ;;
    *) return ;;
esac

for file in "${HOME}/.bashrc.d/"[0-9]*; do
    if test -r "${file}"; then
        # shellcheck disable=SC1090
        . "${file}"
    fi
done
