if [[ -f /usr/share/git/git-prompt.sh ]]; then
    source /usr/share/git/git-prompt.sh
fi

PROMPT_COMMAND=__prompt_command

__prompt_command() {

    local last_exit_status="$?"

    local FG_DEFAULT='\[\033[39m\]'
    local FG_RED='\[\033[31m\]'
    local FG_CYAN='\[\033[36m\]'
    local FG_YELLOW='\[\033[33m\]'
    local DIM_ON='\[\033[2m\]'
    local RESET='\[\033[0m\]'

    PS1="${DIM_ON}"

    if [[ "${last_exit_status}" != 0 ]]; then
        PS1+="=> ${FG_RED}${last_exit_status}${FG_DEFAULT}\n"
    fi

    PS1+="\u@\h:\w"

    # nix shell
    if [[ -n $IN_NIX_SHELL ]]; then
        PS1+=" (${FG_CYAN}nix${FG_DEFAULT})"
    fi

    # python venv
    if [[ -n $VIRTUAL_ENV ]]; then
        PS1+=" (${FG_YELLOW}venv${FG_DEFAULT})"
    fi

    # git branch
    local git_branch
    git_branch=$(__git_ps1 | sed s/[\(\)\ ]//g)
    if [[ -n $git_branch ]]; then
        if [[ $git_branch == *"main"* ]] || [[ $git_branch == *"master"* ]]; then
            git_branch="${FG_RED}$git_branch${FG_DEFAULT}"
        fi
        PS1+=" (git:$git_branch)"
    fi

    PS1+="\n\$${RESET} "

}
