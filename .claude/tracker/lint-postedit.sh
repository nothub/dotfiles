#!/usr/bin/env bash
set -euo pipefail

file_path=$(jq -r '.tool_input.file_path // empty')

test -n "$file_path" || exit 0
test -f "$file_path" || exit 0

case "$file_path" in
    *.sh)
        shellcheck "$file_path"
        ;;
    *.go)
        gofmt -w "$file_path"
        ;;
esac
