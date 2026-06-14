#!/usr/bin/env bash
set -euo pipefail

run_if_available() {
    command -v "$1" &> /dev/null && "$@"
}

file_path=$(jq -r '.tool_input.file_path // empty')

test -n "$file_path" || exit 0
test -f "$file_path" || exit 0

case "$file_path" in
    *.sh)
        run_if_available shellfmt "$file_path"
        run_if_available shellcheck "$file_path"
        ;;
    *.go)
        run_if_available gofmt -w "$file_path"
        ;;
esac
