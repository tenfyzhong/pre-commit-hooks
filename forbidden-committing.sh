#!/usr/bin/env bash

# This script is a pre-commit hook that checks if the commit message contains
# the string "FORBIDDEN-COMMITTING". If it does, the commit is aborted.

set -e

user=$(git config --get user.name)
FORBIDDEN_STRING=" FORBIDDEN-COMMITTING $user "

if git diff --cached | grep '^\+' | grep -v '^\+\+\+' | grep -q "$FORBIDDEN_STRING"; then
    echo "Error: Your staged changes contain the forbidden string: '$FORBIDDEN_STRING'." >&2
    echo "Please remove this string from your staged files and try again." >&2
    exit 1
fi

exit 0
