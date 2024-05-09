# pre-commit-hooks
Some hooks for [pre-commit](https://pre-commit.com/).

# Usage
## Using pre-commit-hooks with pre-commit
Add this to you .pre-commit-config.yaml
```yaml
-   repo: https://github.com/tenfyzhong/pre-commit-hooks
    rev: v0.1.0  # Use the ref you want to point at
    hooks:
    -   id: do-not-commit-swap-file
    # -   id: ...
```

## Hooks available
### `do-not-commit-swap-file`
Prevent swap files from being committed.
A swap file is the editor backup file, the file name of it likes `.foo.swp`
