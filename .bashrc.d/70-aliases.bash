if test -r "${HOME}/.bash_aliases"; then
    # shellcheck disable=SC1090,SC1091
    source "${HOME}/.bash_aliases"
fi

alias ll="ls -lAh"

alias cd..="cd .."

alias record="LC_ALL='en_US.UTF-8' asciinema rec -i 4"

alias clear-caches-java="rm -rf ~/.m2/repository/ ; rm -rf ~/.gradle/caches/"

alias o="xdg-open"

if command -v hx > /dev/null; then
    alias e="hx"
elif command -v vim > /dev/null; then
    alias e="vim"
elif command -v nvim > /dev/null; then
    alias e="vi"
elif command -v micro > /dev/null; then
    alias e="micro"
elif command -v nano > /dev/null; then
    alias e="nano"
elif command -v sensible-editor > /dev/null; then
    alias e="sensible-editor"
else
    alias e="xdg-open"
fi

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

alias git-submodules-update="git pull --recurse-submodules && git submodule update --remote --recursive"
alias git-contribs="git log --all | sed -n 's/Author: //p' | sort -u"
alias git-hotstuff="git log --name-only --pretty=format: | grep -v '^\s*$' | sort | uniq -c | sort -nr"

alias passgen="pwgen --ambiguous --secure 14 2 | sed -z 's/\n/+/'"

alias nmap-scan="sudo nmap -T3 -F -O --traceroute"

alias docker-jupyter='docker run --name jupyter -it --rm -p 8888:8888 jupyter/all-spark-notebook:latest'

alias click-loop='while (true); do sleep 1; xdotool click 1; done'

alias md='glow -p'

alias k='kubectl'

alias go-coverage='go test -v ./... -covermode=count -coverprofile=coverage.out && go tool cover -func=coverage.out -o=coverage.out'

alias trivy='docker run --rm -v /tmp/trivy-cache:/root/.cache -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image'
