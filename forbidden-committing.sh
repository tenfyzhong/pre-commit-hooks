#!/usr/bin/env bash

# This script is a pre-commit hook that checks if the commit message contains
# the string "FORBIDDEN-COMMITTING". If it does, the commit is aborted.

set -e

FORBIDDEN_STRING="FORBIDDEN-COMMITTING"

if git diff -U0 --cached | grep -q "$FORBIDDEN_STRING"; then
    echo "Error: Your commit message contains the forbidden string: '$FORBIDDEN_STRING'." >&2
    echo "Please remove this string from your commit message and try again." >&2
    exit 1
fi

exit 0
