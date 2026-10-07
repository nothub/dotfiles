# shellcheck shell=bash
# shellcheck source=/dev/null

HISTCONTROL=ignoreboth
HISTSIZE=4096
HISTTIMEFORMAT='%F %T '

shopt -s histappend

# 98-prompt.bash chains this after __prompt_command
PROMPT_COMMAND='history -a'
