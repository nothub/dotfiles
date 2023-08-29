# ignore if non-interactive
case $- in
*i*) ;;
*) return ;;
esac

shopt -s checkwinsize \
    expand_aliases \
    histappend

HISTCONTROL=ignoredups
HISTFILESIZE=50000
HISTSIZE=10000
HISTTIMEFORMAT="%F %T "

for file in ~/.bashrc.d/[0-9]*; do
    if test -r "${file}"; then
        # shellcheck disable=SC1090
        . "${file}"
    fi
done
