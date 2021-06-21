PROMPT_COMMAND=__prompt_command

__prompt_command() {

  local EXIT="$?"

  local DEFAULT='\[\e[39m\]'
  local     RED='\[\e[31m\]'
  local  DIM_ON='\[\e[2m\]'
  local DIM_OFF='\[\e[22m\]'

  PS1=""
  PS1+="${DIM_ON}"
  # user
  PS1+="\u"
  PS1+="@"
  # host
  PS1+="\h"
  PS1+=":"
  # dir
  PS1+="\w"
  # venv indicator
  PS1+=$(if [ -z ${VIRTUAL_ENV+x} ]; then echo ""; else echo " (venv)"; fi)
  # git branch
  PS1+=$(__git_ps1)
  PS1+="\n"
  if [ $EXIT != 0 ]; then
    PS1+="${RED}\$${DEFAULT} "
  else
    PS1+="\$ "
  fi
  PS1+="${DIM_OFF}"

}
