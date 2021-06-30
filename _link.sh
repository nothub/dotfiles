#!/usr/bin/env bash

set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

mkdir -p "$HOME/.local/bin/"
if [ ! -f "$HOME/.local/bin/reclink" ]; then
  echo "installing reclink"
  curl --progress-bar "https://raw.githubusercontent.com/nothub/reclink/master/reclink.py" -o "$HOME/.local/bin/reclink"
  chmod +x "$HOME/.local/bin/reclink"
fi

"$HOME/.local/bin/reclink" --source . --target "$HOME" --replace --quiet --ignore ".git" ".gitignore" "_link.sh"
