# locales
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LANGUAGE="en_US"
export LOCALE_ARCHIVE="/usr/lib/locale/locale-archive" # https://nixos.wiki/wiki/Locales

export TERM=xterm-256color

export EDITOR=/usr/bin/micro

# docker rootless
if test -S "$XDG_RUNTIME_DIR/docker.sock"; then
  export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/docker.sock"
fi

export ANSIBLE_STDOUT_CALLBACK="yaml"

export MC_EULA="true"

# spyware opt-out
export DO_NOT_TRACK="1"
export GOTELEMETRY="off"
export DOTNET_CLI_TELEMETRY_OPTOUT="true"
