#!/usr/bin/env bash

if [ -z "$1" ]; then
    echo "Missing commit message file" >&2
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "File not found: $1" >&2
    exit 1
fi

user=$(git config --get user.name)
if ! grep -q "Signed-off-by: $user" "$1"; then
    echo "Sign-off not found" >&2
    exit 1
fi

exit 0
