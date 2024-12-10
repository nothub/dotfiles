find_goroot() {

    if test -d "${HOME}/go"; then
        latest_version=$(ls "${HOME}/go" | grep -E "^go[0-9]+\.[0-9]+\.[0-9]+$" | sort -V | tail -n 1)
        if test -n "${latest_version}"; then
            export GOROOT="${HOME}/go/${latest_version}"
            return
        fi
    fi

    if test -d "${HOME}/go/bin"; then
        export GOROOT="${HOME}/go"
        return
    fi

    if test -d "/usr/local/go/bin"; then
        export GOROOT="/usr/local/go"
        return
    fi

    if test -d "/usr/go/bin"; then
        export GOROOT="/usr/go"
        return
    fi

}

if test -z "${GOROOT}"; then
    find_goroot
fi

if test -n "${GOROOT}"; then
    add_path "${GOROOT}/bin"
fi
