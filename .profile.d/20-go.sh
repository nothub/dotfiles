# shellcheck shell=sh

find_goroot() {

    if test -d "${HOME}/.local/go/bin"; then
        export GOROOT="${HOME}/.local/go"
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
    echo "\$GOROOT = ${GOROOT}" >> "${HOME}/.profile.log"
fi
