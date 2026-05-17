---
name: bash-script
description: Write or edit Bash scripts to automate tasks like setup, testing, building, running, using curl, jq, ffmpeg.
---

All scripts start with a shebang and safe-mode:

```
#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
```

If the script operates on project-relative paths, resolve the project root explicitly and `cd` there before performing file operations. Prefer a simple, readable project-root detection method appropriate for the repository.

Write log output to stderr:

```
echo "foobar" >&2
```

For processing JSON, use `jq`.

For processing videos, use `ffmpeg`.

For downloading files, use `curl`.
