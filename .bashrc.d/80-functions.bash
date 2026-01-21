# shellcheck shell=bash

# regex grep bash history
function hse() { grep --text -E "$1" "${HOME}/.bash_history"; }

# git tag delete
function git-tagd() { git tag -d "$1" && git push origin :refs/tags/"$1"; }

# ssh port tunnel
function sshtunnel() { echo "digging tunnel from $1:$2 to localhost:$2" && ssh -L "$2":localhost:"$2" "$1"; }

# ddg
function d() { ddgr --expand "$@"; }

# latest nixos packages hash
function nix-pkg-hash() {
    echo >&2 "latest nixpkgs (nixos-unstable):"
    curl --fail --location --silent --show-error https://api.github.com/repos/NixOS/nixpkgs/commits/nixos-unstable | jq -r '.sha'
}

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

function video_conv_mp4() {
    ffmpeg -i "${1}" -c copy "${1%.*}.mp4"
}

function freemem() {
    kb=$(cat /proc/meminfo | grep -F 'MemAvailable:' | awk '{print $2}')
    mb=$((kb / 1024))
    gb=$((mb / 1024))
    echo "${gb}"
}

function sort_in_place() {
    f="$(mktemp)"
    cp "${1}" "${f}"
    cat "${f}" | sort -g > "${1}"
    rm -f "${f}"
}

function mc_version() {
    curl -fsSL 'https://launchermeta.mojang.com/mc/game/version_manifest.json' \
        | jq -r '.versions | map(select(.type == "release")) | .[0].id'
}

function forgejo_version() {
    dig +short -t TXT release.forgejo.org | tr -d '"' | cut -d'=' -f2
}

function lan_cidrs() {
    ip a | grep -F '    inet ' | awk '{print $2}'
}
