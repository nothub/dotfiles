if [[ -f /usr/share/git/git-prompt.sh ]]; then
    # shellcheck disable=SC1091
    source /usr/share/git/git-prompt.sh
fi

PROMPT_COMMAND=__prompt_command

__prompt_command() {

    local last_exit_status="$?"

    local ansi_fg_default='\[\033[39m\]'
    local ansi_fg_red='\[\033[31m\]'
    local ansi_fg_blue='\[\033[34m\]'
    local ansi_fg_cyan='\[\033[36m\]'
    local ansi_dim_on='\[\033[2m\]'
    local ansi_reset='\[\033[0m\]'

    PS1="${ansi_dim_on}"

    if [[ ${last_exit_status} != 0 ]]; then
        PS1+="=> ${ansi_fg_red}${last_exit_status}${ansi_fg_default}\n"
    fi

    PS1+="\u@\h:\w"

    local infos
    infos=()

    if [[ -n $IN_NIX_SHELL ]]; then
        if test "${DEVBOX_SHELL_ENABLED}" = "1"; then
            infos+=("env:${ansi_fg_blue}devbox${ansi_fg_default}")
        else
            infos+=("env:${ansi_fg_cyan}nix${ansi_fg_default}")
        fi
    fi

    if [[ -n $VIRTUAL_ENV ]]; then
        infos+=("env:venv")
    fi

    local git_branch
    git_branch=$(__git_ps1 | sed s/[\(\)\ ]//g)
    if [[ -n $git_branch ]]; then
        if [[ $git_branch == *"main"* ]] || [[ $git_branch == *"master"* ]] || [[ $git_branch == *"trunk"* ]]; then
            git_branch="${ansi_fg_red}${git_branch}${ansi_fg_default}"
        fi
        infos+=("git:${git_branch}")
    fi

    if [[ ${#infos[@]} -gt 0 ]]; then
        PS1+=" ["
        for i in "${infos[@]}"; do
            PS1+=" ${i}"
        done
        PS1+=" ]"
    fi

    PS1+="\n"
    PS1+="${ansi_dim_on}" # workaround for broken ansi state (lost ansi flags prior to last newline) on window resize
    PS1+='$'
    PS1+="${ansi_reset}"
    PS1+=" "

}
