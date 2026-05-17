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

If the script is operating on any relative path, make sure to cd to the relevant directory:

```
# go to project root
cd "$(realpath "$(dirname "$(readlink -f "$0")")")/.."
```

Write log output to stderr:

```
echo "foobar" >&2
```

For processing JSON, use `jq`.

For processing videos, use `ffmpeg`.

For downloading files, use `curl`.
