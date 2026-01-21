# shellcheck shell=bash

if test -r "${HOME}/.bash_aliases"; then
    # shellcheck disable=SC1090,SC1091
    source "${HOME}/.bash_aliases"
fi

alias l="ls -lAh"
alias ll="ls -lAh"

alias cd..="cd .."

alias record="LC_ALL='en_US.UTF-8' asciinema rec -i 4"

alias clear-caches-java="rm -rf ~/.m2/repository/ ; rm -rf ~/.gradle/caches/"

if command -v xdg-open > /dev/null; then
    alias o="xdg-open"
fi

if test -n "${EDITOR}"; then
    alias e='${EDITOR}'
fi

alias rg="rg --hidden --max-columns=1000"

alias ssh-copy-id-pass="ssh-copy-id -o PreferredAuthentications=password -o PubkeyAuthentication=no"

alias ssh-pass="ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no"

alias path='echo $PATH | sed -e "s/:/\n/g"'

alias cal="ncal -b -M"
alias kw='date +%W'

alias python="python3"
alias pip="pip3"

# need to set $TERM for these, otherwise some stuff breaks
alias ssh="TERM=xterm-256color ssh"
alias vagrant="TERM=xterm-256color vagrant"

alias icat="kitty +kitten icat"

alias passgen="pwgen --ambiguous --secure 14 2 | sed -z 's/\n/+/'"

alias nmap-scan="sudo nmap -v -T3 -A"
alias nmap-scan-fast="sudo nmap -v -T3 -F"

alias click-loop='while (true); do sleep 1; xdotool click 1; done'

alias md='glow -p'

alias k='kubectl'

alias go-coverage='go test -v ./... -covermode=count -coverprofile=coverage.out && go tool cover -func=coverage.out -o=coverage.out'

alias ai='ollama run deepseek-r1:14b'
