export DOTFILES="${HOME}/.dotfiles"

# Minecraft EULA
export MC_EULA=true

# NetData tracking
export DO_NOT_TRACK=1

# dotNet tracking
export DOTNET_CLI_TELEMETRY_OPTOUT=true

# docker rootless
if [[ -S $XDG_RUNTIME_DIR/docker.sock ]]; then
    export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
fi

# locales
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANGUAGE=en_US
export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive # https://nixos.wiki/wiki/Locales

# ansible
export ANSIBLE_STDOUT_CALLBACK=yaml
