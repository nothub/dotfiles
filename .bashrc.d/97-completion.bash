if ! shopt -oq posix; then
  if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    . /usr/share/bash-completion/bash_completion
  elif [[ -f /etc/bash_completion ]]; then
    . /etc/bash_completion
  fi
fi
bind 'set completion-ignore-case on'

if command -v pandoc >/dev/null 2>&1; then
  eval "$(pandoc --bash-completion)"
fi
