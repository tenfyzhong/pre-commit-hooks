#!/usr/bin/env bash

set -e

if [ -z "$*" ]; then
    echo "Error: No forbidden remote URL parts specified for this hook." >&2
    exit 1
fi

remote_url="$PRE_COMMIT_REMOTE_URL"

if [ -z "$remote_url" ]; then
    echo "Error: PRE_COMMIT_REMOTE_URL is not set. Cannot check remote." >&2
    # Exit 1 to be safe and indicate an error.
    exit 1
fi

for forbidden_url_part in "$@"; do
    if [[ "$remote_url" == *"$forbidden_url_part"* ]]; then
        echo "Push to remote '$remote_url' is forbidden because it contains '$forbidden_url_part'." >&2
        exit 1
    fi
done

# If no forbidden parts are found, the push is allowed.
exit 0
