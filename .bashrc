# ignore if non-interactive
case $- in
*i*) ;;
*) return ;;
esac

shopt -s checkwinsize \
    expand_aliases \
    histappend

HISTCONTROL=ignoreboth
HISTSIZE=4096

for file in "${HOME}/.bashrc.d/"[0-9]*; do
    if test -r "${file}"; then
        # shellcheck disable=SC1090
        . "${file}"
    fi
done
