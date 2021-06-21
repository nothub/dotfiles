# history search
function hse() { cat ~/.bash_history | grep "$1"; }
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
