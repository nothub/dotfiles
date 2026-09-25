# shellcheck shell=bash
# shellcheck source=/dev/null

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

function go-bump() {
    sed -i -E "s/^go [0-9]+\.[0-9]+\.[0-9]+/go $(curl -fsSL 'https://go.dev/VERSION?m=text' | head -n 1 | sed -e 's/^go//')/" go.mod
}

function lan_cidrs() {
    ip a | grep -F '    inet ' | awk '{print $2}'
}

function gh-repos() {
    local page=1 resp chunk out=''
    while ((page <= 50)); do
        resp=$(curl -fsSL --netrc-file "${HOME}/.config/curl/github.netrc" \
            -H 'Accept: application/vnd.github+json' \
            -H 'X-GitHub-Api-Version: 2022-11-28' \
            "https://api.github.com/user/repos?per_page=100&page=${page}&affiliation=owner") || return 1
        jq -e 'type == "array"' <<< "$resp" > /dev/null 2>&1 \
            || {
                echo "ghrepos: unexpected response on page $page" >&2
                return 1
            }
        (($(jq 'length' <<< "$resp") == 0)) && break
        chunk=$(jq -r '.[] | select(.fork == false and .archived == false) | .name' <<< "$resp")
        test -n "$chunk" && out+="$chunk"$'\n'
        ((page++))
    done
    test -n "$out" || return 0
    printf '%s' "$out" | LC_ALL=C sort -u
}

function claude-temp() (
    dir="$(mktemp -d)" || return 1
    trap 'rm -rf -- "$dir"' EXIT
    cd -- "$dir" || return 1
    claude "$@"
)
