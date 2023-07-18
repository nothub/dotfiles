#!/usr/bin/env bash

set -o errexit
set -o pipefail

rand() {
  if [[ -n $2 ]]; then count=$2; else count=1; fi
  echo -n "$1" | grep -Eo '\S{1}' | shuf | head --lines "$count"
}

buf+="$(rand "☀☄🌎🌑🚀🛰🛸" 3)"
buf+="$(for _ in {1..7}; do rand ",;'~*°✦⊚⊙⨀⋇"; done)"
buf+="$(for _ in {1..20}; do rand ".⋅∙⋆"; done)"
buf+="$(for _ in {1..750}; do echo -n " "; done)"

echo "${buf}" | grep -Eo '[^\n]{1}' | shuf | tr -d '\n' | grep -Eo '.{60}'
