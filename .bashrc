# dont process if noninteractive
case $- in
*i*) ;;
  *) return ;;
esac

shopt -s checkwinsize \
         expand_aliases \
         histappend

bind 'set completion-ignore-case on'

HISTCONTROL=ignoredups
HISTFILESIZE=50000
HISTSIZE=10000
HISTTIMEFORMAT="%F %T "

for f in ~/.bashrc.d/[0-9]*; do
  [[ -r $f ]] && . "$f"
done
