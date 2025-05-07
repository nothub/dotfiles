# shellcheck shell=bash

alias git-submodules-update="git pull --recurse-submodules && git submodule update --remote --recursive"

alias git-contribs="git log --all | sed -n 's/Author: //p' | sort -u"

alias git-hotstuff="git log --name-only --pretty=format: | grep -v '^\s*$' | sort | uniq -c | sort -nr"
