#!/usr/bin/env sh

set -eu

shellcheck --shell sh ".profile"
find ".profile.d" -type f \
    -exec shellcheck --shell sh {} \;

shellcheck --shell bash ".bashrc"
find ".bashrc.d" -type f \
    -exec shellcheck --shell bash {} \;
