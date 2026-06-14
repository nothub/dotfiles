#!/usr/bin/env bash
set -euo pipefail

input=$(cat)

file_path=$(sed -n 's/.*"file_path" *: *"\([^"]*\)".*/\1/p' <<< "$input")

if [[ "$file_path" =~ .*/.claude/skills/([^/]+)/SKILL\.md$ ]]; then
    name="${BASH_REMATCH[1]}"
    kind="skill"
elif [[ "$file_path" =~ .*/.claude/commands/([^/]+)\.md$ ]]; then
    name="${BASH_REMATCH[1]}"
    kind="command"
else
    exit 0
fi

csv="$HOME/.claude/tracker/usage.csv"

if [ ! -f "$csv" ]; then
    mkdir -p "$(dirname "$csv")"
    printf 'type,name,count\n' > "$csv"
fi

if grep -q "^$kind,$name," "$csv"; then
    count=$(grep "^$kind,$name," "$csv" | cut -d, -f3)
    sed -i "s/^$kind,$name,.*/$kind,$name,$((count + 1))/" "$csv"
else
    printf '%s,%s,1\n' "$kind" "$name" >> "$csv"
fi
