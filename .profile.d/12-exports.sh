# locales
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LANGUAGE="en_US"

# https://nixos.wiki/wiki/Locales
if test -z "${LOCALE_ARCHIVE}" && test -f "/usr/lib/locale/locale-archive"; then
    export LOCALE_ARCHIVE="/usr/lib/locale/locale-archive"
fi

export TERM=xterm-256color

if command -v hx > /dev/null; then
    EDITOR="$(which hx)"
    export EDITOR
elif command -v vim > /dev/null; then
    EDITOR="$(which vim)"
    export EDITOR
elif command -v vi > /dev/null; then
    EDITOR="$(which vi)"
    export EDITOR
elif command -v nano > /dev/null; then
    EDITOR="$(which nano)"
    export EDITOR
elif command -v micro > /dev/null; then
    EDITOR="$(which micro)"
    export EDITOR
fi

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
