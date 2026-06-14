#!/usr/bin/env bash
set -euo pipefail

file_path=$(jq -r '.tool_input.file_path // empty')

test -n "$file_path" || exit 0

case "$file_path" in
    */.claude/skills/*/SKILL.md)
        name="${file_path#*/.claude/skills/}"
        name="${name%/SKILL.md}"
        kind="skill"
        ;;
    */.claude/commands/*.md)
        name="${file_path#*/.claude/commands/}"
        name="${name%.md}"
        kind="command"
        ;;
    */.claude/agents/*.md)
        name="${file_path#*/.claude/agents/}"
        name="${name%.md}"
        kind="agent"
        ;;
    */.claude/references/*.md|*/.claude/skills/*/references/*.md|*/.claude/skills/*/*.md)
        name="${file_path##*/}"
        name="${name%.md}"
        kind="reference"
        ;;
    *)
        exit 0
        ;;
esac

csv="$HOME/.claude/tracker/usage.csv"

if test ! -f "$csv"; then
    mkdir -p "${csv%/*}"
    printf 'type,name,count\n' > "$csv"
fi

if line=$(grep -m1 "^$kind,$name," "$csv"); then
    count=${line##*,}
    sed -i "s/^$kind,$name,.*/$kind,$name,$((count + 1))/" "$csv"
else
    printf '%s,%s,1\n' "$kind" "$name" >> "$csv"
fi
