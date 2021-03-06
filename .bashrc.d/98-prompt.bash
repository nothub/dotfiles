if [[ -f /usr/share/git/git-prompt.sh ]]; then
  source /usr/share/git/git-prompt.sh
fi

PROMPT_COMMAND=__prompt_command

__prompt_command() {

  local exit_code="$?"

  local FG_DEFAULT='\[\033[39m\]'
  local FG_RED='\[\033[31m\]'
  local DIM_ON='\[\033[2m\]'
  local RESET='\[\033[0m\]'

  PS1="${DIM_ON}"

  if [[ "$exit_code" != 0 ]]; then
    PS1+="=> ${FG_RED}$exit_code${FG_DEFAULT}\n"
  fi

  PS1+="\u@\h:\w"

  # git branch
  git_branch=$(__git_ps1 | sed s/[\(\)\ ]//g)
  if [[ -n $git_branch ]]; then
    if [[ $git_branch == *"main"* ]] || [[ $git_branch == *"master"* ]]; then
      git_branch="${FG_RED}$git_branch${FG_DEFAULT}"
    fi
    PS1+=" ($git_branch)"
  fi

  # python venv
  if [[ -n $VIRTUAL_ENV ]]; then
    PS1+=" (venv)"
  fi

  PS1+="\n\$${RESET} "

}
