#!/usr/bin/env bash

_cwd=$(pwd)
_root=$(git rev-parse --show-toplevel)
# cd the git root directory
cd "$_root" || exit 1

exec 1>&2
fish -c todo

cd "$_cwd" || exit 1
