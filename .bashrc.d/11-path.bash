if [ -d "$HOME/.local/bin" ]; then
  [[ ":$PATH:" != *":${HOME}/.local/bin:"* ]] && PATH="${HOME}/.local/bin:${PATH}"
fi

if [ -d "/usr/local/go/bin" ]; then
  [[ ":$PATH:" != *":/usr/local/go/bin:"* ]] && PATH="/usr/local/go/bin:${PATH}"
fi

if [ -d "$HOME/.cargo/bin" ]; then
  [[ ":$PATH:" != *":${HOME}/.cargo/bin:"* ]] && PATH="${HOME}/.cargo/bin:${PATH}"
fi
if [ -f "$HOME/.cargo/env" ]; then
  [[ ":$PATH:" != *":${HOME}/.cargo/env:"* ]] && PATH="${HOME}/.cargo/env:${PATH}"
fi
