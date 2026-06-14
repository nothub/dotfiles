#!/usr/bin/env bash
set -euo pipefail

file_path=$(jq -r '.tool_input.file_path // empty')

test -n "$file_path" || exit 0
test -f "$file_path" || exit 0

case "$file_path" in
    *.sh)
        # format
        if command -v shellfmt &> /dev/null; then
            shellfmt "$file_path"
        fi
        # lint
        if command -v shellcheck &> /dev/null; then
            shellcheck "$file_path"
        fi
        ;;
    *.go)
        # format
        if command -v gofmt &> /dev/null; then
            gofmt -w "$file_path"
        fi
        ;;
esac
