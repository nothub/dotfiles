install_nerdtree() {
    local dir="${HOME}/.vim/pack/vendor/start/nerdtree"
    if test -d "${dir}"; then return; fi
    if ! command -v git 1>/dev/null; then return; fi
    if ! command -v vim 1>/dev/null; then return; fi
    echo >&2 "installing nerdtree"
    git clone https://github.com/preservim/nerdtree.git "${dir}"
    vim -u NONE -c "helptags ${dir}/doc" -c q
}

install_nerdtree
