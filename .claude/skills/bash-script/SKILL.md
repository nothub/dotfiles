---
name: bash-script
description: Write or edit Bash scripts following safe-mode conventions for this project
---

## Bash

All scripts start with a shebang `#!/usr/bin/env bash` and safe-mode:

```
#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
```

If the script is operating on existing files, make sure to cd to the project root.
For example `./scripts/build.sh` needs this:

```
# go to project root
cd "$(realpath "$(dirname "$(readlink -f "$0")")")/.."
```

Write log output with echo or printf if arguments need rendering. Write to stderr with >&2.

For processing JSON, use:`jq`.
For processing videos, use `ffmpeg`.
For other stuff, prioritize coreutils.
