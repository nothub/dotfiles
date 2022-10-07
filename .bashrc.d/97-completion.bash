# shellcheck source=/dev/null

bind 'set completion-ignore-case on'

if shopt -oq posix; then return; fi

if [[ -r /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
elif [[ -r /etc/bash_completion ]]; then
    source /etc/bash_completion
fi

if command -v pandoc &>/dev/null; then
    source <(pandoc --bash-completion)
fi

if command -v podman &>/dev/null; then
    source <(podman completion bash)
fi

if command -v k3s &>/dev/null; then
    source <(k3s completion bash)
fi

if command -v kubectl &>/dev/null; then
    source <(kubectl completion bash)
fi

if command -v nerdctl &>/dev/null; then
    source <(nerdctl completion bash)
fi

if command -v packwiz &>/dev/null; then
    source <(packwiz completion bash)
fi
