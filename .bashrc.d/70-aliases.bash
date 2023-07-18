alias ll="ls -lAh"
alias cll="clear && ll"

alias rm="echo 'rm bad, use trash instead!' >&2 ; false"

alias nano="vim"

alias cd..="cd .."

alias record="LC_ALL='en_US.UTF-8' asciinema rec -i 4"

alias clear-caches-java="rm -rf ~/.m2/repository/ ; rm -rf ~/.gradle/caches/"

alias o="xdg-open"

if command -v vim >/dev/null 2>&1; then
    alias e="vim"
elif command -v vi >/dev/null 2>&1; then
    alias e="vi"
elif command -v nano >/dev/null 2>&1; then
    alias e="nano"
elif command -v pico >/dev/null 2>&1; then
    alias e="pico"
elif command -v idea >/dev/null 2>&1; then
    alias e="idea -e"
elif command -v geany >/dev/null 2>&1; then
    alias e="geany"
else
    alias e="xdg-open"
fi

alias ssh-pass="ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no"

alias path='echo $PATH | sed -e "s/:/\n/g"'

alias cal="ncal -b -M"

alias python="python3"
alias pip="pip3"

alias ssh="TERM=xterm-256color ssh" # kitty breaks stuff because of dumb politics otherwise
alias icat="kitty +kitten icat"

if command -v git >/dev/null 2>&1; then
    alias git-submodules-update="git pull --recurse-submodules && git submodule update --remote --recursive"
    alias git-contribs="git log --all | sed -n 's/Author: //p' | sort -u"
fi

if [[ -r ${HOME}/.bash_aliases ]]; then
    source "${HOME}/.bash_aliases"
fi

if [[ -r "${HOME}/nextcloud/Stuff/keepass.tc" ]]; then
    alias keepass-mount="sudo cryptsetup open /home/hub/nextcloud/Stuff/keepass.tc keepass"
    alias keepass-umount="sudo umount /dev/mapper/keepass; sudo cryptsetup luksClose keepass"
fi

# sdkman
alias sdk8="sdk-switch-java 8"
alias sdk11="sdk-switch-java 11"
alias sdk17="sdk-switch-java 17"

alias nmap-scan="sudo nmap -T3 -F -O --traceroute"

alias docker-jupyter='docker run --name jupyter -it --rm -p 8888:8888 jupyter/all-spark-notebook:latest'

alias click-loop='while (true); do sleep 1; xdotool click 1; done'
