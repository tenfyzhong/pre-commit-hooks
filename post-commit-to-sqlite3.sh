#!/usr/bin/env bash
format() {
    if [ $# -ne 1 ]; then
        exit 0
    fi
    echo "$1" | grep -v -e '^#' | sed "s/'/%27/g"
}

dir=~/.local/state/commit-msg-log

if [ ! -d "$dir" ]; then
    mkdir -p ~/.local/state/commit-msg-log
fi

year=$(date +%Y)
db="$dir/$year.sqlite3"
if [ ! -f "$db" ]; then
    sqlite3 "$db" 'CREATE TABLE IF NOT EXISTS git_commit_msg(id INTEGER PRIMARY KEY, dir TEXT, repo TEXT, branch TEXT, commit_id TEXT, remote TEXT, branch_desc TEXT, desc TEXT, author_date TEXT, create_time TEXT);'
    sqlite3 "$db" 'CREATE INDEX IF NOT EXISTS key_dir on git_commit_msg(dir);'
    sqlite3 "$db" 'CREATE INDEX IF NOT EXISTS key_repo on git_commit_msg(repo);'
    sqlite3 "$db" 'CREATE INDEX IF NOT EXISTS key_commit_id on git_commit_msg(commit_id);'
    sqlite3 "$db" 'CREATE INDEX IF NOT EXISTS key_create_time on git_commit_msg(create_time);'
fi

cwd=$(pwd)
toplevel=$(git rev-parse --show-toplevel)

dir=$(basename "$cwd")
repo=$(basename "$toplevel")
branch=$(git branch --show-current)
commit_id=$(git log --format="%H" -n 1)
remote=$(git remote get-url origin)
branch_desc=$(git config --get branch."$branch".description)
branch_desc=$(format "$branch_desc")
desc=$(git log --format="%B" -n 1)
desc=$(format "$desc")
author_date=$(git log --format="%ad" --date=format-local:'%Y-%m-%d %H:%M:%S' -n 1)
create_time=$(date +'%Y-%m-%d %H:%M:%S')

sqlite3 "$db" "INSERT INTO git_commit_msg(dir,repo,branch,commit_id,remote,branch_desc,desc,author_date,create_time) values ('$dir','$repo','$branch','$commit_id','$remote','$branch_desc','$desc','$author_date','$create_time');"
