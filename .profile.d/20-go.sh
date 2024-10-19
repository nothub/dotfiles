if test -z "${GOROOT}" && test -d "${HOME}/go"; then
    latest_version=$(ls "${HOME}/go" | grep -E "^go[0-9]+\.[0-9]+\.[0-9]+$" | sort -V | tail -n 1)
    if test -n "${latest_version}"; then
        export GOROOT="${HOME}/go/${latest_version}"
    fi
fi

if test -z "${GOROOT}" && test -d "/usr/local/go"; then
    export GOROOT="/usr/local/go"
fi

if test -z "${GOROOT}"; then
    export PATH="${PATH}:${GOROOT}/bin"
fi
