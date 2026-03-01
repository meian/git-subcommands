# git-subcommands

Custom Git subcommands implemented as executable files named `git-*`.

日本語版: [README.ja.md](README.ja.md)

## Subcommands

- `git latest <branch>`
  - Switch to the target branch and update it from remote with fast-forward only.
- `git local-branch [branch-pattern]`
  - Select a local branch with `fzf` and switch to it.
  - If `branch-pattern` is provided, only matching local branches are candidates.
- `git merged [-clean]`
  - List local branches that are already merged into the current branch.
  - With `-clean`, delete the listed merged local branches.
- `git last [-n]`
  - Show the latest commit diff.
  - With `-n` (positive integer), show the diff of the commit `n` behind `HEAD` (for example `-1`, `-2`).

## Requirements

- `git`
- `fzf` (required for `git local-branch`)

## Setup

1. Make scripts executable:
   - `chmod +x src/git-latest src/git-local-branch src/git-merged src/git-last`
2. Add the `src/` directory to your `PATH`.

Then you can run these as normal Git subcommands:

- `git latest main`
- `git local-branch feature`
- `git merged -clean`
- `git last -1`

## Test

- `bash test/run.sh`
