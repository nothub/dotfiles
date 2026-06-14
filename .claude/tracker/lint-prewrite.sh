#!/usr/bin/env bash
set -euo pipefail

input=$(cat)

file_path=$(jq -r '.tool_input.file_path // empty' <<< "$input")

test -n "$file_path" || exit 0

case "$file_path" in
    *.sh)
        tmp=$(mktemp --suffix=.sh)
        trap 'rm -f "$tmp"' EXIT
        jq -r '.tool_input.content // empty' <<< "$input" > "$tmp"
        shellcheck "$tmp"
        ;;
    *.go)
        tmp=$(mktemp --suffix=.go)
        trap 'rm -f "$tmp"' EXIT
        jq -r '.tool_input.content // empty' <<< "$input" > "$tmp"
        diff=$(gofmt -d "$tmp") || true
        if test -n "$diff"; then
            printf '%s\n' "$diff"
            exit 1
        fi
        ;;
esac
