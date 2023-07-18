# regex grep bash history
function hse() { grep --text -E "$1" "${HOME}/.bash_history"; }
export -f hse

# git tag delete
function git-tagd() { git tag -d "$1" && git push origin :refs/tags/"$1"; }
export -f git-tagd

# ssh port tunnel
function sshtunnel() { echo "digging tunnel from $1:$2 to localhost:$2" && ssh -L "$2":localhost:"$2" "$1"; }
export -f sshtunnel

# reset file perms
function perms-reset-to-default() { find "$1" -type d -exec chmod 755 {} + && find "$1" -type f -exec chmod 644 {} +; }
export -f perms-reset-to-default

# ddg
function d() { ddgr --expand "$@"; }
export -f d

# latest nixos packages hash
function nix-pkg-hash() {
    echo >&2 "latest nixpkgs (nixos-unstable):"
    curl --fail --location --silent --show-error https://api.github.com/repos/NixOS/nixpkgs/commits/nixos-unstable | jq -r '.sha'
}
export -f nix-pkg-hash

# psgrep
function psgrep() { ps -aux | grep -E "PID.*TTY.*TIME|$*" | grep -v grep; }
export -f psgrep

# sdkman helper
function sdk-switch-java() {
    if [[ -z ${SDKMAN_DIR} ]]; then
        echo >&2 "Error: $SDKMAN_DIR not set"
        return 1
    fi
    if [[ $# -le 0 ]]; then
        echo >&2 "Error: missing version argument"
        return 1
    fi
    sdk use java "$(find "${SDKMAN_DIR}/candidates/java/" -maxdepth 1 -type d -regex ".*\/java\/${1}.*" -exec basename {} \; | sort -n -r | head -n 1)"
}
