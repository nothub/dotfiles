---
name: bash-script
description: Write, review, or modify Bash scripts for automation, setup, testing, builds, local tooling, command wrappers, and data-processing pipelines. Use when working with shell scripts that should be safe, readable, pipe-friendly, POSIX-aware where practical, and may use tools such as curl, jq, ffmpeg, find, sed, awk on absolute or project-relative paths.
---

All scripts start with a shebang and safe-mode:

```
#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
```

If the script operates on project-relative paths, resolve the project root explicitly and `cd` there before performing
file operations. Prefer a simple, readable project-root detection method appropriate for the repository.

Write log output to stderr:

```
echo "foobar" >&2
```

For processing JSON, use `jq`.

For processing videos, use `ffmpeg`.

For downloading files, use `curl`.

After every code change, lint the file with `shellcheck` and format it with:

```
shfmt \
    --write \
    --simplify \
    --indent 4 \
    --binary-next-line \
    --case-indent \
    --space-redirects \
    {{path}}
```
