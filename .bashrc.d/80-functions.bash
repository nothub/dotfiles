# history search
function hse() { cat ~/.bash_history | grep "$1"; }
export -f hse

# git tag delete
function git-tagd() { git tag -d "$1" && git push origin :refs/tags/"$1"; }
export -f git-tagd

# ssh port tunnel
function sshtunnel() { echo "digging tunnel from $1:$2 to localhost:$2" && ssh -L "$2":localhost:"$2" "$1"; }
export -f sshtunnel

# port open check
function port-open() { timeout 1 bash -c "</dev/tcp/$1/$2" && echo "$1:$2 open" || echo "$1:$2 closed"; }
export -f port-open

# reset file perms
function perms-reset-to-default() { find "$1" -type d -exec chmod 755 {} + && find "$1" -type f -exec chmod 644 {} +; }
export -f perms-reset-to-default

# ddg
function d() { ddgr --expand "$@"; }
export -f d
