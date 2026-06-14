#!/usr/bin/env bash
# PostToolUse hook: logs skill and command reads to ~/.claude/tracker/usage.csv
set -euo pipefail

input=$(cat)

file_path=$(printf '%s' "$input" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('tool_input', {}).get('file_path', ''))
except Exception:
    print('')
")

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
mkdir -p "$(dirname "$csv")"

if [ ! -f "$csv" ]; then
    printf 'timestamp,type,name\n' > "$csv"
fi

printf '%s,%s,%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$kind" "$name" >> "$csv"
