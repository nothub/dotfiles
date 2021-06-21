# colors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias diff='diff --color=auto'
fi

# less non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if [ -d "$HOME/.sdkman" ] && [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
  export SDKMAN_DIR="$HOME/.sdkman"
  source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

# scrup
if [ ! -f "$HOME/.local/bin/scrup" ]; then
  echo "installing scrup"
  curl --progress-bar "https://raw.githubusercontent.com/nothub/reclink/master/reclink.py" -o "$HOME/.local/bin/scrup"
  chmod +x "$HOME/.local/bin/scrup"
fi
