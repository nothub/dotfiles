#!/usr/bin/env bash

set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

if [ ! -f "_reclink" ]; then
  echo "installing reclink"
  curl --progress-bar "https://raw.githubusercontent.com/nothub/reclink/master/reclink.py" -o _reclink
  chmod +x _reclink
fi

./_reclink -s . -t "$HOME" -rq -i ".git" ".gitignore" "_link.sh"
