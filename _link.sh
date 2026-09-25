#!/usr/bin/env bash

set -eu
set -o pipefail

cd "$(dirname "$(realpath "$0")")"

.local/bin/reclink \
    --source . \
    --target "$HOME" \
    --replace \
    --quiet \
    --ignore \
    ".git" \
    ".gitattributes" \
    ".gitignore" \
    ".idea" \
    ".vscode" \
    "_fmt.sh" \
    "_link.sh" \
    "_lint.sh" \
    "AGENTS.md" \
    "CLAUDE.md" \
    "README.md" \
    "renovate.json"
