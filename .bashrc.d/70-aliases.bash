alias ll="ls -lAh"
alias cll="clear && ll"

alias nano="vim"

alias cd..="cd .."

alias record="LC_ALL='en_US.UTF-8' asciinema rec -i 4"

alias clear-caches-java="rm -rf ~/.m2/repository/ ; rm -rf ~/.gradle/caches/"

alias o="xdg-open"

alias ssh-pass="ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no"

alias path='echo $PATH | sed -e "s/:/\n/g"'

alias cal="ncal -b -M"

alias python="python3"
alias pip="pip3"

# kitty breaks stuff because of dumb politics otherwise
alias ssh="TERM=xterm-256color ssh"

if command -v git >/dev/null 2>&1; then
  alias git-submodules-update="git pull --recurse-submodules && git submodule update --remote --recursive"
  alias git-contribs="git log --all | sed -n 's/Author: //p' | sort -u"
fi

if [[ -f ~/.bash_aliases ]]; then
  . ~/.bash_aliases
fi
