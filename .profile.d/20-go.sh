if test -z "${GOROOT}"; then
    if test -d "${HOME}/go"; then
        latest_version=$(ls "${HOME}/go" | grep -E "^go[0-9]+\.[0-9]+\.[0-9]+$" | sort -V | tail -n 1)
        if test -n "${latest_version}"; then
            export GOROOT="${HOME}/go/${latest_version}"
        elif test -d "${HOME}/go/bin"; then
            export GOROOT="${HOME}/go"
        fi
    elif test -d "/usr/local/go"; then
        export GOROOT="/usr/local/go"
    fi
fi
if test -n "${GOROOT}"; then
    add_path "${GOROOT}/bin"
fi
