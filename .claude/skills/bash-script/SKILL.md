---
name: bash-script
description: Write or review Bash scripts. Use for automation, setup, builds, local tooling, and data pipelines. Safe, pipe-friendly, and POSIX-aware.
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
