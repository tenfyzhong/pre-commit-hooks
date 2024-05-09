#!/usr/bin/env bats

setup() {
    temp=$(mktemp -d)
    export PROJ="$temp"
    echo "PROJ:$PROJ"
    mkdir -p "$PROJ/bin"
    export PATH=$PROJ/bin:$PATH
    unset GIT_WORK_REMOTE
    unset GIT_WORK_NAME
    unset GIT_WORK_EMAIL
    unset GIT_PERSONAL_NAME
    unset GIT_PERSONAL_EMAIL
}

teardown() {
    rm -rf "$PROJ"
    unset PROJ
}

mock_git() {
    export url=
    export name=
    export email=
    while [[ $# -gt 0 ]]; do
        case $1 in
            --url)
                export url=$2
                shift
                shift
                ;;
            --name)
                export name=$2
                shift
                shift
                ;;
            --email)
                export email=$2
                shift
                shift
                ;;
            *)
                return 1
                ;;
        esac
    done

cat << EOF > "$PROJ"/bin/git
if [ \$# -ne 3 ] || [ "\$1" != "config" ] || [ "\$2" != "--get" ]; then
    exit 254
fi
if [ "\$3" = "remote.origin.url" ]; then
        echo $url
elif [ "\$3" = "user.name" ]; then
        echo $name
elif [ "\$3" = "user.email" ]; then
        echo $email
else
    exit 10
fi
EOF
chmod +x "$PROJ"/bin/git
}

demock_git() {
    rm -f "$PROJ"/bin/git
    unset url
    unset name
    unset email
}

@test 'GIT_WORK_REMOTE is empty' {
    expect="env: GIT_PERSONAL_NAME / GIT_PERSONAL_EMAIL should not be empty"
    run check-commit-user-name-email.sh
    [ "$output" = "$expect" ]
    [ "$status" -eq 3 ]
}

@test 'GIT_WORK_REMOTE not match' {
    export GIT_WORK_REMOTE=gitlab.com
    mock_git --url google.com --name zhongtenghui --email zhongtenghui@gmail.com
    run check-commit-user-name-email.sh
    expect="env: GIT_PERSONAL_NAME / GIT_PERSONAL_EMAIL should not be empty"
    run check-commit-user-name-email.sh
    [ "$output" = "$expect" ]
    [ "$status" -eq 3 ]
    demock_git
}

@test 'GIT_WORK_NAME is empty' {
    export GIT_WORK_REMOTE=gitlab.com
    mock_git --url gitlab.com --name zhongtenghui --email zhongtenghui@gmail.com
    run check-commit-user-name-email.sh
    expect="env: GIT_WORK_NAME / GIT_WORK_EMAIL should not be empty"
    run check-commit-user-name-email.sh
    echo "GIT_WORK_REMOTE:$GIT_WORK_REMOTE"
    echo "GIT_WORK_NAME:$GIT_WORK_NAME"
    echo "GIT_WORK_EMAIL:$GIT_WORK_EMAIL"
    echo "output: $output"
    echo "status: $status"
    [ "$output" = "$expect" ]
    [ "$status" -eq 2 ]
    demock_git
}

@test 'GIT_WORK_EMAIL is empty' {
    export GIT_WORK_REMOTE=gitlab.com
    export GIT_WORK_NAME=zhongtenghui
    mock_git --url gitlab.com --name zhongtenghui --email zhongtenghui@gmail.com
    run check-commit-user-name-email.sh
    expect="env: GIT_WORK_NAME / GIT_WORK_EMAIL should not be empty"
    run check-commit-user-name-email.sh
    echo "GIT_WORK_REMOTE:$GIT_WORK_REMOTE"
    echo "GIT_WORK_NAME:$GIT_WORK_NAME"
    echo "GIT_WORK_EMAIL:$GIT_WORK_EMAIL"
    echo "output: $output"
    echo "status: $status"
    [ "$output" = "$expect" ]
    [ "$status" -eq 2 ]
    demock_git
}

@test 'GIT_WORK_NAME not match' {
    export GIT_WORK_REMOTE=gitlab.com
    export GIT_WORK_NAME=zhongtenghui
    export GIT_WORK_EMAIL=zhongtenghui@gmail.com
    mock_git --url gitlab.com --name tenfyzhong --email zhongtenghui@gmail.com
    run check-commit-user-name-email.sh
    expect=$(cat <<"EOF"
name/email should config to zhongtenghui/zhongtenghui@gmail.com
run command:
  git config user.name zhongtenghui; git config user.email zhongtenghui@gmail.com
EOF
)
    run check-commit-user-name-email.sh
    echo "GIT_WORK_REMOTE:$GIT_WORK_REMOTE"
    echo "GIT_WORK_NAME:$GIT_WORK_NAME"
    echo "GIT_WORK_EMAIL:$GIT_WORK_EMAIL"
    echo "expect:$expect"
    echo "output:$output"
    echo "status:$status"
    [ "$output" = "$expect" ]
    [ "$status" -eq 1 ]
    demock_git
}

@test 'GIT_WORK_EMAIL not match' {
    export GIT_WORK_REMOTE=gitlab.com
    export GIT_WORK_NAME=zhongtenghui
    export GIT_WORK_EMAIL=zhongtenghui@gmail.com
    mock_git --url gitlab.com --name zhongtenghui --email tenfyzhong@gmail.com
    run check-commit-user-name-email.sh
    expect=$(cat <<"EOF"
name/email should config to zhongtenghui/zhongtenghui@gmail.com
run command:
  git config user.name zhongtenghui; git config user.email zhongtenghui@gmail.com
EOF
)
    run check-commit-user-name-email.sh
    echo "GIT_WORK_REMOTE:$GIT_WORK_REMOTE"
    echo "GIT_WORK_NAME:$GIT_WORK_NAME"
    echo "GIT_WORK_EMAIL:$GIT_WORK_EMAIL"
    echo "expect:$expect"
    echo "output:$output"
    echo "status:$status"
    [ "$output" = "$expect" ]
    [ "$status" -eq 1 ]
    demock_git
}

@test 'GIT_PERSONAL_NAME is empty' {
    export GIT_WORK_REMOTE=gitlab.com
    export GIT_WORK_NAME=zhongtenghui
    export GIT_WORK_EMAIL=zhongtenghui@gmail.com
    mock_git --url github.com --name tenfyzhong --email tenfy@tenfy.cn

    run check-commit-user-name-email.sh
    expect="env: GIT_PERSONAL_NAME / GIT_PERSONAL_EMAIL should not be empty"
    run check-commit-user-name-email.sh
    [ "$output" = "$expect" ]
    [ "$status" -eq 3 ]
    demock_git
}

@test 'GIT_PERSONAL_EMAIL is empty' {
    export GIT_WORK_REMOTE=gitlab.com
    export GIT_WORK_NAME=zhongtenghui
    export GIT_WORK_EMAIL=zhongtenghui@gmail.com
    export GIT_PERSONAL_NAME=tenfyzhong
    mock_git --url github.com --name tenfyzhong --email tenfy@tenfy.cn

    run check-commit-user-name-email.sh
    expect="env: GIT_PERSONAL_NAME / GIT_PERSONAL_EMAIL should not be empty"
    run check-commit-user-name-email.sh
    [ "$output" = "$expect" ]
    [ "$status" -eq 3 ]
    demock_git
}

@test 'GIT_PERSONAL_NAME not match' {
    export GIT_WORK_REMOTE=gitlab.com
    export GIT_WORK_NAME=zhongtenghui
    export GIT_WORK_EMAIL=zhongtenghui@gmail.com
    export GIT_PERSONAL_NAME=tenfyzhong
    export GIT_PERSONAL_EMAIL=tenfy@tenfy.cn
    mock_git --url github.com --name zhongtenghui --email tenfy@tenfy.cn
    run check-commit-user-name-email.sh
    expect=$(cat <<"EOF"
name/email should config to tenfyzhong/tenfy@tenfy.cn
run command:
  git config user.name tenfyzhong; git config user.email tenfy@tenfy.cn
EOF
)
    run check-commit-user-name-email.sh
    echo "GIT_WORK_REMOTE:$GIT_WORK_REMOTE"
    echo "GIT_WORK_NAME:$GIT_WORK_NAME"
    echo "GIT_WORK_EMAIL:$GIT_WORK_EMAIL"
    echo "expect:$expect"
    echo "output:$output"
    echo "status:$status"
    [ "$output" = "$expect" ]
    [ "$status" -eq 1 ]
    demock_git
}

@test 'GIT_PERSONAL_EMAIL not match' {
    export GIT_WORK_REMOTE=gitlab.com
    export GIT_WORK_NAME=zhongtenghui
    export GIT_WORK_EMAIL=zhongtenghui@gmail.com
    export GIT_PERSONAL_NAME=tenfyzhong
    export GIT_PERSONAL_EMAIL=tenfy@tenfy.cn
    mock_git --url github.com --name tenfyzhong --email zhongtenghui
    run check-commit-user-name-email.sh
    expect=$(cat <<"EOF"
name/email should config to tenfyzhong/tenfy@tenfy.cn
run command:
  git config user.name tenfyzhong; git config user.email tenfy@tenfy.cn
EOF
)
    run check-commit-user-name-email.sh
    echo "GIT_WORK_REMOTE:$GIT_WORK_REMOTE"
    echo "GIT_WORK_NAME:$GIT_WORK_NAME"
    echo "GIT_WORK_EMAIL:$GIT_WORK_EMAIL"
    echo "expect:$expect"
    echo "output:$output"
    echo "status:$status"
    [ "$output" = "$expect" ]
    [ "$status" -eq 1 ]
    demock_git
}
