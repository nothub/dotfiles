#!/usr/bin/env sh

set -eu

.local/bin/reclink \
    --source "$(dirname "$(readlink -f -- "$0")")" \
    --target "$HOME" \
    --replace \
    --quiet \
    --ignore \
    ".git" \
    ".gitattributes" \
    ".idea" \
    ".vscode" \
    "_fmt.sh" \
    "_link.sh" \
    "_lint.sh" \
    "README.md"
