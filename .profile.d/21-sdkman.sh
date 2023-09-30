if test -r "${HOME}/.sdkman/bin/sdkman-init.sh"; then
  export SDKMAN_DIR="${HOME}/.sdkman"
  # shellcheck disable=SC1090,SC1091
  . "${HOME}/.sdkman/bin/sdkman-init.sh"
fi
