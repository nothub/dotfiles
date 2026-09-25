# shellcheck shell=bash
# shellcheck source=/dev/null

# colors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
if test -x /usr/bin/dircolors; then
    if test -d "${HOME}/.dircolors"; then
        eval "$(dircolors -b "${HOME}/.dircolors")"
    else
        eval "$(dircolors -b)"
    fi
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias diff='diff --color=auto'
fi

# less non-text input files
command -v lesspipe > /dev/null && test -x /usr/bin/lesspipe && eval "$(SHELL=/bin/sh lesspipe)"
