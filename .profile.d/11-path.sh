add_path() {
  if test ! -d "${1}"; then
    # skip nonexistent dirs
    return
  fi
  case $PATH in
  *$1*)
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

# go
add_path "${HOME}/.go/bin"
add_path "${HOME}/go/bin"
add_path "/usr/local/go/bin"

# nim
add_path "${HOME}/.nim-lang/bin"

# zig
add_path "${HOME}/.zig"

# rust
add_path "${HOME}/.cargo/bin"
add_path "${HOME}/.cargo/env"

# platformio
add_path "${HOME}/.platformio/penv/bin"

# jetbrains shortcuts
add_path "${HOME}/.local/share/JetBrains/Toolbox/scripts"

# android
add_path "${HOME}/adb-fastboot/platform-tools"
