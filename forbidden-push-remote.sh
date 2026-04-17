#!/usr/bin/env bash

set -e

is_positive_integer() {
    case "$1" in
        '' | *[!0-9]*)
            return 1
            ;;
    esac

    [ "$1" -gt 0 ]
}

parent_command() {
    ps -o command= -p "$1" 2>/dev/null || true
}

parent_pid() {
    ps -o ppid= -p "$1" 2>/dev/null | tr -d ' ' || true
}

is_git_push_command() {
    local command=$1
    local -a parts

    read -r -a parts <<< "$command" || true

    for ((i = 0; i < ${#parts[@]}; i++)); do
        if [ "${parts[$i]}" != "push" ]; then
            continue
        fi

        for ((j = 0; j < i; j++)); do
            case "${parts[$j]}" in
                git | */git)
                    return 0
                    ;;
            esac
        done

        return 1
    done

    return 1
}

find_push_command() {
    local pid=$PPID
    local depth=0
    local command

    while is_positive_integer "$pid" && [ "$pid" -gt 1 ] && [ "$depth" -lt 10 ]; do
        command=$(parent_command "$pid")
        if is_git_push_command "$command"; then
            printf '%s\n' "$command"
            return 0
        fi

        pid=$(parent_pid "$pid")
        depth=$((depth + 1))
    done

    return 1
}

matches_current_remote() {
    local candidate=$1

    if [ -n "${PRE_COMMIT_REMOTE_NAME-}" ] && [ "$candidate" = "$PRE_COMMIT_REMOTE_NAME" ]; then
        return 0
    fi

    [ "$candidate" = "$remote_url" ]
}

push_explicitly_specifies_remote() {
    local command
    local -a parts
    local expect_repo_value=0
    local expect_option_value=0
    local token
    local push_index=-1

    command=$(find_push_command) || return 1
    read -r -a parts <<< "$command" || true

    for ((i = 0; i < ${#parts[@]}; i++)); do
        if [ "${parts[$i]}" = "push" ]; then
            push_index=$i
            break
        fi
    done

    if [ "$push_index" -lt 0 ]; then
        return 1
    fi

    for ((i = push_index + 1; i < ${#parts[@]}; i++)); do
        token=${parts[$i]}

        if [ "$expect_repo_value" -eq 1 ]; then
            matches_current_remote "$token" && return 0
            expect_repo_value=0
            continue
        fi

        if [ "$expect_option_value" -eq 1 ]; then
            expect_option_value=0
            continue
        fi

        case "$token" in
            --)
                i=$((i + 1))
                if [ "$i" -lt "${#parts[@]}" ] && matches_current_remote "${parts[$i]}"; then
                    return 0
                fi
                return 1
                ;;
            --repo=*)
                matches_current_remote "${token#--repo=}"
                return
                ;;
            --repo)
                expect_repo_value=1
                continue
                ;;
            --receive-pack | --exec | --push-option | -o)
                expect_option_value=1
                continue
                ;;
            --receive-pack=* | --exec=* | --push-option=* | -o?*)
                continue
                ;;
            -*)
                continue
                ;;
            *)
                matches_current_remote "$token"
                return
                ;;
        esac
    done

    return 1
}

if [ $# -eq 0 ]; then
    echo "Error: No forbidden remote URL parts specified for this hook." >&2
    exit 1
fi

remote_url="$PRE_COMMIT_REMOTE_URL"

if [ -z "$remote_url" ]; then
    echo "Error: PRE_COMMIT_REMOTE_URL is not set. Cannot check remote." >&2
    # Exit 1 to be safe and indicate an error.
    exit 1
fi

if push_explicitly_specifies_remote; then
    exit 0
fi

for forbidden_url_part in "$@"; do
    if [[ "$remote_url" == *"$forbidden_url_part"* ]]; then
        echo "Push to remote '$remote_url' is forbidden because it contains '$forbidden_url_part'." >&2
        exit 1
    fi
done

# If no forbidden parts are found, the push is allowed.
exit 0
