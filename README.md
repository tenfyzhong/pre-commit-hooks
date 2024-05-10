# pre-commit-hooks
Some hooks for [pre-commit](https://pre-commit.com/).

# Usage
## Using pre-commit-hooks with pre-commit
Add this to you .pre-commit-config.yaml
```yaml
-   repo: https://github.com/tenfyzhong/pre-commit-hooks
    rev: 0.1.0  # Use the ref you want to point at
    hooks:
    -   id: do-not-commit-swap-file
    # -   id: ...
```

## Hooks available
### `do-not-commit-swap-file`
Prevent swap files from being committed.
A swap file is the editor backup file, the file name of it likes `.foo.swp`


### `check-commit-user-name-email`
Check the user name and email match the remote or not before commit to index.
You should set environment below first:
- `GIT_WORK_REMOTE` the special remote to match
- `GIT_WORK_NAME` the user name for the work remote
- `GIT_WORK_EMAIL` the user email for the work remote
- `GIT_PERSONAL_NAME` the default name not match the work remote
- `GIT_PERSONAL_EMAIL` the default email not match the work remote
