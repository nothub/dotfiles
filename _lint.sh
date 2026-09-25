#!/usr/bin/env sh

set -eu

shellcheck --shell sh ".profile"
find ".profile.d" -type f \
    -exec shellcheck --shell sh {} \;

shellcheck --shell bash ".bashrc"
find ".bashrc.d" -type f \
    -exec shellcheck --shell bash {} \;

# TODO: check there are no stale links left in `.local/share/bash-completion/completions/`, each link in there should have a corresponding script in `.local/bin/`.
