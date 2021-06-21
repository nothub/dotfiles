alias ll="ls -lAh"
alias cll="clear && ll"

alias clear-caches-java="rm -rf ~/.m2/repository/ ; rm -rf ~/.gradle/caches/"

alias o="xdg-open"

alias path="echo $PATH | sed -e 's/:/\n/g'"

alias python="python3"
alias pip="pip3"

apt-get -v >/dev/null 2>&1
if [ $? == 0 ]; then
  # full apt upgrade and cleanup
  alias update-full="sudo apt-get -qyf install \
  && sudo dpkg --configure -a \
  && sudo apt-get -qy update \
  && sudo apt-get -qy --with-new-pkgs upgrade \
  && sudo apt-get -qy clean \
  && sudo apt-get -qy autoremove"
  # update kernel headers and extra modules
  alias update-kernel-stuff="sudo apt-get install -qy linux-headers-$(uname -r) linux-modules-extra-$(uname -r)"
fi

git version >/dev/null 2>&1
if [ $? == 0 ]; then
  # list repo contributors
  alias git-contribs="git log --all | sed -n 's/Author: //p' | sort -u"
fi

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi
