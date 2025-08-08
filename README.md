# pre-commit-hooks

Some hooks for [pre-commit](https://pre-commit.com/).

# Usage

## Using pre-commit-hooks with pre-commit

Add this to you .pre-commit-config.yaml

```yaml
-   repo: https://github.com/tenfyzhong/pre-commit-hooks
    rev: 0.1.0  # Use the ref you want to point at
    hooks:
    -   id: forbid-swap-file
    # -   id: ...
```

## Hooks available

### `forbid-swap-file`

Prevent swap files from being committed.
A swap file is a editor's backup file, the file name of it would likes `.foo.swp`

### `check-commit-user-name-email`

Check the user name and email match the remote or not before commit to index.
You should set environment below first:

- `GIT_WORK_REMOTE` the special remote to match
- `GIT_WORK_NAME` the user name for the work remote
- `GIT_WORK_EMAIL` the user email for the work remote
- `GIT_PERSONAL_NAME` the default name not match the work remote
- `GIT_PERSONAL_EMAIL` the default email not match the work remote

### `forbid-binary`

Prevent binary files from being commited

### `post-commit-to-sqlite3`

This is a hook for stage post-commit. It will dump the commit message to sqlite3 file which locate in `~/.local/state/commit-msg-log/[year].sqlite3`
You can analyse your job by these db files.

### `make-target`

Run make targets before pushing. The target names are passed as arguments to the hook.
Add this to your .pre-commit-config.yaml:

```yaml
-   repo: https://github.com/tenfyzhong/pre-commit-hooks
    rev: 0.1.0
    hooks:
    -   id: make-target
        args: ['lint', 'test']  # The make targets you want to run
```

### `forbidden-committing`

This script is a pre-commit hook that checks if any staged file's content contains the string "FORBIDDEN-COMMITTING". If it does, the commit is aborted.

### `check-dco`

Check if the commit message is signed with DCO.
To sign a commit, use `git commit -s`.
