#!/usr/bin/env bash

set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

# https://github.com/nothub/reclink
reclink -s . -t "$HOME" -rq -i ".git" "_link.sh"
