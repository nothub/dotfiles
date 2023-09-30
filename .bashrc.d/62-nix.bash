init_nix() {
    if test -r "${HOME}/.nix-profile/etc/profile.d/nix.sh"; then
        # shellcheck disable=SC1090,SC1091
        source "${HOME}/.nix-profile/etc/profile.d/nix.sh"
    elif test -r "/nix/var/nix/profiles/default/etc/profile.d/nix.sh"; then
        # shellcheck disable=SC1090,SC1091
        source "/nix/var/nix/profiles/default/etc/profile.d/nix.sh"
    fi
}

init_nix
