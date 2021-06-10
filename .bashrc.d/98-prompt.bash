PROMPT_COMMAND=__prompt_command

__prompt_command() {

  local EXIT="$?"
  local RCol='\[\e[0m\]'
  local Red='\[\e[0;31m\]'
  PS1=""

  if [ $UID -eq 0 ]; then PS1+="${Red}\u${RCol}"; else PS1+="\u"; fi
  PS1+="@\h:\w\n"
  if [ $EXIT != 0 ]; then
    PS1+="${Red}\$${RCol} "
  else
    PS1+="\$ "
  fi

}
