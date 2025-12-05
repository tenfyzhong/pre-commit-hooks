#!/usr/bin/env bash

git_dir=$(git rev-parse --git-dir)

# Skip DCO check for merge, cherry-pick, and rebase operations
if [ -f "$git_dir/MERGE_HEAD" ] || \
   [ -f "$git_dir/CHERRY_PICK_HEAD" ] || \
   [ -f "$git_dir/REBASE_HEAD" ] || \
   [ -d "$git_dir/rebase-apply" ] || \
   [ -d "$git_dir/rebase-merge" ]; then
    exit 0
fi

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
