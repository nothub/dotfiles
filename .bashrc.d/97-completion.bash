# shellcheck shell=bash
# shellcheck source=/dev/null

bind 'set completion-ignore-case on'

if shopt -oq posix; then return; fi

if [[ -r /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
elif [[ -r /etc/bash_completion ]]; then
    source /etc/bash_completion
fi

should_add() {
    if command -v "${1}" &> /dev/null && ! complete -p | grep "${1}" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

if should_add docker; then
    source <(docker completion bash)
fi

if should_add podman; then
    source <(podman completion bash)
fi

if should_add nerdctl; then
    source <(nerdctl completion bash)
fi

if should_add kubectl; then
    if kubectl api-resources --request-timeout=1s 1> /dev/null 2> /dev/null; then
        source <(kubectl completion bash)
    fi
fi

if should_add k3d; then
    source <(k3d completion bash)
fi

if should_add k3s; then
    source <(k3s completion bash)
fi

if should_add k9s; then
    source <(k9s completion bash)
fi

if should_add kubectx; then
    _kube_contexts() {
        local curr_arg
        curr_arg=${COMP_WORDS[COMP_CWORD]}
        COMPREPLY=("$(compgen -W "- $(kubectl config get-contexts --output='name')" -- "${curr_arg}")")
    }
    complete -F _kube_contexts kubectx
fi

if should_add kubens; then
    _kube_namespaces() {
        local curr_arg
        curr_arg=${COMP_WORDS[COMP_CWORD]}
        COMPREPLY=("$(compgen -W "- $(kubectl get namespaces -o=jsonpath='{range .items[*].metadata.name}{@}{"\n"}{end}')" -- "${curr_arg}")")
    }
    complete -F _kube_namespaces kubens
fi

if should_add hcloud; then
    source <(hcloud completion bash)
fi

if should_add devbox; then
    source <(devbox completion bash)
fi

if should_add pandoc; then
    source <(pandoc --bash-completion)
fi

if should_add tofu; then
    complete -C /usr/bin/tofu tofu
fi

if should_add terraform; then
    complete -C /usr/bin/terraform terraform
fi

if should_add packer; then
    complete -C /usr/bin/packer packer
fi

if should_add deno; then
    if test -f "${HOME}/.local/share/bash-completion/completions/deno.bash"; then
        source "${HOME}/.local/share/bash-completion/completions/deno.bash"
    fi
fi

if should_add talosctl; then
    source <(talosctl completion bash)
fi

if should_add vagrant; then
    # shellcheck disable=SC1090
    source "$(find /opt/vagrant -type f -wholename '*/bash/completion.sh')"
fi
