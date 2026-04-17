# Repository Guidelines

## Project Structure & Module Organization

This repository ships standalone Git hook scripts for `pre-commit`. Each hook lives at the repository root as an executable Bash script such as `forbidden-push-remote.sh` or `check-dco.sh`. The hook manifest is [`.pre-commit-hooks.yaml`](./.pre-commit-hooks.yaml), which defines hook IDs, stages, and entrypoints. Tests live under [`tests/`](./tests), with one `.bats` file per feature area. CI is defined in [`.github/workflows/test.yml`](./test.yml).

## Build, Test, and Development Commands

There is no build step; this project is shell scripts plus tests.

- `make test`: runs all Bats tests with the repository root added to `PATH`.
- `bats tests/*.bats`: runs the full test suite directly.
- `bats tests/forbidden-push-remote.bats`: runs one spec file while iterating on a hook.
- `pre-commit try-repo . forbidden-push-remote --all-files`: smoke-test a hook through `pre-commit`.

Install `bats` locally before running tests.

## Coding Style & Naming Conventions

Write hooks in Bash and keep them executable with `#!/usr/bin/env bash`. Prefer small, single-purpose scripts and descriptive helper names such as `push_explicitly_specifies_remote`. Follow existing formatting in this repo: shell bodies use 4-space indentation; YAML uses 2 spaces; no trailing whitespace. Name new hooks as kebab-case shell files ending in `.sh`, then register the matching hook ID in `.pre-commit-hooks.yaml`.

## Testing Guidelines

Use TDD for behavior changes: add or update a failing Bats test first, confirm it fails for the expected reason, then implement the minimal fix. Keep tests reusable and place them in `tests/<feature>.bats`. Cover both success and failure paths, especially exit codes and stderr/stdout messages for hook scripts.

## Commit & Pull Request Guidelines

Recent history uses short conventional-style subjects such as `feat(make-target): ...` and `fix: ...`; keep that format. All commits must be signed off with `git commit -s`. Pull requests should explain the hook behavior change, reference the related issue when applicable, and include test evidence such as `make test` output. If a hook’s usage, arguments, or stage changes, update both `README.md` and `.pre-commit-hooks.yaml` in the same PR.
