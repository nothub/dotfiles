# colors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
if [[ -x /usr/bin/dircolors ]]; then
    if [[ -d "${HOME}/.dircolors" ]]; then
        eval "$(dircolors -b "${HOME}/.dircolors")"
    else
        eval "$(dircolors -b)"
    fi
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias diff='diff --color=auto'
fi

# less non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# sdkman
if [[ -r "${HOME}/.sdkman/bin/sdkman-init.sh" ]]; then
    export SDKMAN_DIR="${HOME}/.sdkman"
    source "${HOME}/.sdkman/bin/sdkman-init.sh"
fi

# vim plugins
if command -v vim >/dev/null 2>&1; then
    if [[ ! -d ${HOME}/.vim/pack/vendor/start/nerdtree ]]; then
        echo >&2 "installing nerdtree"
        git clone https://github.com/preservim/nerdtree.git "${HOME}/.vim/pack/vendor/start/nerdtree"
        vim -u NONE -c "helptags ${HOME}/.vim/pack/vendor/start/nerdtree/doc" -c q
    fi
fi

# golang
if [[ -d "${HOME}/go" ]]; then
    export GOPATH="${HOME}/go"
fi

# nix
if [[ -d ${HOME}/.nix-profile/etc/profile.d ]]; then
    source "${HOME}/.nix-profile/etc/profile.d/nix-daemon.sh"
    source "${HOME}/.nix-profile/etc/profile.d/nix.sh"
elif [[ -d /nix/var/nix/profiles/default/etc/profile.d ]]; then
    source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
    source "/nix/var/nix/profiles/default/etc/profile.d/nix.sh"
fi

# direnv
if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook bash)"
fi
