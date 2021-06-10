# dont process if noninteractive
case $- in
*i*) ;;
  *) return ;;
esac

shopt -s checkwinsize \
         expand_aliases \
         histappend

bind 'set completion-ignore-case on'
bind 'TAB:menu-complete'

HISTCONTROL=ignoredups
HISTFILESIZE=20000
HISTSIZE=10000
HISTTIMEFORMAT="%F %T "

for i in ~/.bashrc.d/[0-9]*; do
  . "$i"
done
