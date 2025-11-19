# shellcheck shell=bash

if test -n "${SSH_AUTH_SOCK}"; then
    # load all private keys in ~/.ssh
    find "${HOME}/.ssh" -type f -exec file {} \; \
        | grep 'OpenSSH private key' \
        | cut -d: -f1 \
        | xargs -I {} ssh-add -q {}
fi
