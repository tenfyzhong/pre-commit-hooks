#!/usr/bin/env bash

set -e

if [ "$#" -eq 0 ]; then
    exit 0
fi

for target in "$@"; do
    if ! make -n "$target" >/dev/null 2>&1; then
      echo "make target '$target' not found, skipping."
      continue
    fi

    make "$target"
done
