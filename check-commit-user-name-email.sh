#!/usr/bin/env bash

prompt_user() {
    echo -e "name/email should config to $1/$2" >&2
    echo -e "run command:" >&2
    echo -e "  git config user.name $1; git config user.email $2" >&2
}

remote=$(git config --get remote.origin.url)
name=$(git config --get user.name)
email=$(git config --get user.email)

check() {
    if [ "$1" != "$name" ] || [ "$2" != "$email" ]; then
        prompt_user "$1" "$2"
        exit 1
    fi
}

if [[ -n "$GIT_WORK_REMOTE" ]] && [[ "$remote" == *"$GIT_WORK_REMOTE"* ]]; then
    if [ -z "$GIT_WORK_NAME" ] || [ -z "$GIT_WORK_EMAIL" ]; then
        echo "env: GIT_WORK_NAME / GIT_WORK_EMAIL should not be empty" >&2
        exit 2
    fi
    check "$GIT_WORK_NAME" "$GIT_WORK_EMAIL"
else
    if [ -z "$GIT_PERSONAL_NAME" ] || [ -z "$GIT_PERSONAL_EMAIL" ]; then
        echo "env: GIT_PERSONAL_NAME / GIT_PERSONAL_EMAIL should not be empty" >&2
        exit 3
    fi
    check "$GIT_PERSONAL_NAME" "$GIT_PERSONAL_EMAIL"
fi
