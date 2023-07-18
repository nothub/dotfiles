#!/usr/bin/env bash

set -euo pipefail

.local/bin/reclink \
  --source "$(dirname "$(readlink -f -- "$0")")" \
  --target "$HOME" \
  --replace \
  --quiet \
  --ignore ".git" ".gitignore" "_link.sh" ".idea" ".vscode"
