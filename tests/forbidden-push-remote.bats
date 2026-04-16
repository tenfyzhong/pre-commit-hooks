#!/usr/bin/env bats

setup() {
    temp=$(mktemp -d)
    export PROJ="$temp"
    mkdir -p "$PROJ/bin"
    export PATH="$PROJ/bin:$PATH"
    unset PRE_COMMIT_REMOTE_NAME
    unset PRE_COMMIT_REMOTE_URL
    unset MOCK_PS_DEFAULT_PID
}

teardown() {
    rm -rf "$PROJ"
    unset PROJ
}

mock_ps() {
cat << 'EOF' > "$PROJ"/bin/ps
#!/usr/bin/env bash
set -eu

if [ "$#" -ne 4 ] || [ "$1" != "-o" ] || [ "$3" != "-p" ]; then
    exit 254
fi

field=${2%=}
pid=$4

if [ "$field" != "command" ] && [ "$field" != "ppid" ]; then
    exit 253
fi

var_name="MOCK_PS_${field^^}_$pid"
if [ -n "${!var_name-}" ]; then
    printf '%s\n' "${!var_name}"
    exit 0
fi

if [ -n "${MOCK_PS_DEFAULT_PID-}" ]; then
    var_name="MOCK_PS_${field^^}_${MOCK_PS_DEFAULT_PID}"
    if [ -n "${!var_name-}" ]; then
        printf '%s\n' "${!var_name}"
        exit 0
    fi
fi

exit 1
EOF
chmod +x "$PROJ"/bin/ps
}

@test 'forbids pushing to forbidden remote when using default push target' {
    export PRE_COMMIT_REMOTE_NAME=origin
    export PRE_COMMIT_REMOTE_URL=https://github.com/some-org/repo.git
    export MOCK_PS_DEFAULT_PID=100
    export MOCK_PS_COMMAND_100='python -m pre_commit.commands.hook_impl'
    export MOCK_PS_PPID_100=200
    export MOCK_PS_COMMAND_200='git push'
    export MOCK_PS_PPID_200=1
    mock_ps

    run ./forbidden-push-remote.sh 'github.com/some-org/'

    [ "$status" -eq 1 ]
    [ "$output" = "Push to remote 'https://github.com/some-org/repo.git' is forbidden because it contains 'github.com/some-org/'." ]
}

@test 'allows push when remote is explicitly specified' {
    export PRE_COMMIT_REMOTE_NAME=origin
    export PRE_COMMIT_REMOTE_URL=https://github.com/some-org/repo.git
    export MOCK_PS_DEFAULT_PID=100
    export MOCK_PS_COMMAND_100='python -m pre_commit.commands.hook_impl'
    export MOCK_PS_PPID_100=200
    export MOCK_PS_COMMAND_200='git push -u origin HEAD'
    export MOCK_PS_PPID_200=1
    mock_ps

    run ./forbidden-push-remote.sh 'github.com/some-org/'

    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test 'does not treat refspec as an explicit remote' {
    export PRE_COMMIT_REMOTE_NAME=origin
    export PRE_COMMIT_REMOTE_URL=https://github.com/some-org/repo.git
    export MOCK_PS_DEFAULT_PID=100
    export MOCK_PS_COMMAND_100='python -m pre_commit.commands.hook_impl'
    export MOCK_PS_PPID_100=200
    export MOCK_PS_COMMAND_200='git push HEAD:main'
    export MOCK_PS_PPID_200=1
    mock_ps

    run ./forbidden-push-remote.sh 'github.com/some-org/'

    [ "$status" -eq 1 ]
    [ "$output" = "Push to remote 'https://github.com/some-org/repo.git' is forbidden because it contains 'github.com/some-org/'." ]
}
