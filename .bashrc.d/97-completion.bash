# shellcheck source=/dev/null

bind 'set completion-ignore-case on'

if shopt -oq posix; then return; fi

if [[ -r /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
elif [[ -r /etc/bash_completion ]]; then
    source /etc/bash_completion
fi

should_add() {
    if command -v "${1}" &>/dev/null && ! complete -p | grep "${1}" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

if should_add pandoc; then
    source <(pandoc --bash-completion)
fi

if should_add podman; then
    source <(podman completion bash)
fi

if should_add k3s; then
    source <(k3s completion bash)
fi

if should_add kubectl; then
    source <(kubectl completion bash)
fi

if should_add nerdctl; then
    source <(nerdctl completion bash)
fi

if should_add packwiz; then
    source <(packwiz completion bash)
fi

if should_add gopass; then
    source <(gopass completion bash)
fi

if should_add hcloud; then
    source <(hcloud completion bash)
fi
