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
    export PATH="$1:${PATH}"
    ;;
  esac
}

# ~/.local/bin
mkdir -p "${HOME}/.local/bin"
add_path "${HOME}/.local/bin"

# appimages
mkdir -p "${HOME}/appimages"
add_path "${HOME}/appimages"

# go
add_path "/usr/local/go/bin"
add_path "${HOME}/go/bin"

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
