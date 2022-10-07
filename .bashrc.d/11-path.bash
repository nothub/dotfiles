add_path() {
    [[ ":$PATH:" != *":$1:"* ]] && PATH="$1:${PATH}"
}

# ~/.local/bin
mkdir -p "${HOME}/.local/bin"
add_path "${HOME}/.local/bin"

# appimages
mkdir -p "${HOME}/appimages"
add_path "${HOME}/appimages"

# go
if [[ -d "/usr/local/go/bin" ]]; then
    add_path "/usr/local/go/bin"
fi
if [[ -d "${HOME}/go/bin" ]]; then
    add_path "${HOME}/go/bin"
fi

# nim
if [[ -d "${HOME}/.nim-lang/bin" ]]; then
    add_path "${HOME}/.nim-lang/bin"
fi

# zig
if [[ -d "${HOME}/.zig" ]]; then
    add_path "${HOME}/.zig"
fi

# rust
if [[ -d "${HOME}/.cargo/bin" ]]; then
    add_path "${HOME}/.cargo/bin"
fi
if [[ -f "${HOME}/.cargo/env" ]]; then
    add_path "${HOME}/.cargo/env"
fi

# platformio
if [[ -d "${HOME}/.platformio/penv/bin" ]]; then
    add_path "${HOME}/.platformio/penv/bin"
fi

# jetbrains shortcuts
if [[ -d "${HOME}/.local/share/JetBrains/Toolbox/scripts" ]]; then
    add_path "${HOME}/.local/share/JetBrains/Toolbox/scripts"
fi
