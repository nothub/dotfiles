# regex grep bash history
function hse() { grep --text -E "$1" "${HOME}/.bash_history"; }
export -f hse

# git tag delete
function git-tagd() { git tag -d "$1" && git push origin :refs/tags/"$1"; }
export -f git-tagd

# ssh port tunnel
function sshtunnel() { echo "digging tunnel from $1:$2 to localhost:$2" && ssh -L "$2":localhost:"$2" "$1"; }
export -f sshtunnel

# ddg
function d() { ddgr --expand "$@"; }
export -f d

# latest nixos packages hash
function nix-pkg-hash() {
    echo >&2 "latest nixpkgs (nixos-unstable):"
    curl --fail --location --silent --show-error https://api.github.com/repos/NixOS/nixpkgs/commits/nixos-unstable | jq -r '.sha'
}
export -f nix-pkg-hash

function topp() {
    local proc_infos
    proc_infos="$(pgrep -f "$1")"
    if test -z "${proc_infos}"; then
        echo >&2 "no such process"
        return 1
    fi
    top -p "$(echo "${proc_infos}" | cut -d " " -f 3 | head -n 1)"
}

function semver_next_major() {
    git describe --abbrev=0 | awk -F '.' '{$1+=1; OFS="."; print}' | tr ' ' '.'
}

function semver_next_minor() {
    git describe --abbrev=0 | awk -F '.' '{$2+=1; OFS="."; print}' | tr ' ' '.'
}

function semver_next_patch() {
    git describe --abbrev=0 | awk -F '.' '{$3+=1; OFS="."; print}' | tr ' ' '.'
}

function video_shrink() {
    local file
    file="${1}"
    ffmpeg -i "${file}" -vcodec libx265 -crf 24 \
        "${file%.*}-shrink.${file##*.}"
}
