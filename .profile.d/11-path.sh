add_path() {

    if test ! -e "${1}"; then
        # path does not exist, skip silently
        return
    fi

    if test ! -d "${1}"; then
        echo >&2 "${1} is not a directory!"
        return
    fi

    case $PATH in
        *${1}*)
            # already present in $PATH
            ;;
        *)
            # append to $PATH
            export PATH="${PATH}:${1}"
            ;;
    esac

}

# fhs
add_path "/usr/local/bin"
add_path "/usr/bin"
add_path "/bin"
add_path "/usr/local/sbin"
add_path "/usr/sbin"
add_path "/sbin"

# home local
mkdir -p "${HOME}/.local/bin"
add_path "${HOME}/.local/bin"
mkdir -p "${HOME}/.local/appimages"
add_path "${HOME}/.local/appimages"

# neovim
add_path "/opt/nvim-linux64/bin"

# nim
add_path "${HOME}/.nim-lang/bin"

# zig
add_path "${HOME}/.zig"

# rust
add_path "${HOME}/.cargo/bin"

# platformio
add_path "${HOME}/.platformio/penv/bin"

# jetbrains shortcuts
add_path "${HOME}/.local/share/JetBrains/Toolbox/scripts"

# android
add_path "${HOME}/adb-fastboot/platform-tools"
