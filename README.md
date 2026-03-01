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

- `bash` or `zsh` (supported interactive shell environment)
- `git`
- `fzf` (required for `git local-branch`)

## Install

Install from GitHub (default branch):

```bash
curl -fsSL https://raw.githubusercontent.com/meian/git-subcommands/main/install.sh | sh
```

Update an existing installation:

```bash
curl -fsSL https://raw.githubusercontent.com/meian/git-subcommands/main/install.sh | sh -s -- --update
```

Install a specific branch:

```bash
curl -fsSL https://raw.githubusercontent.com/meian/git-subcommands/main/install.sh | sh -s -- --branch feature/my-branch
```

Install a specific tag:

```bash
curl -fsSL https://raw.githubusercontent.com/meian/git-subcommands/main/install.sh | sh -s -- --tag v1.0.0
```

The same installation steps work regardless of your current shell (bash/zsh).

The installer configures interactive shells by adding a managed block to `.bashrc` and `.zshrc` that loads `~/.git-subcommands.rc`.
`~/.git-subcommands.rc` adds `~/.local/share/git-subcommands/src` to `PATH`.

## Usage

After installation, you can run these as normal Git subcommands:

- `git latest main`
- `git local-branch feature`
- `git merged -clean`
- `git last -1`

## Uninstall

Run:

```bash
curl -fsSL https://raw.githubusercontent.com/meian/git-subcommands/main/uninstall.sh | sh
```

or execute the local script:

```bash
./uninstall.sh
```

The uninstaller removes the managed block from `.bashrc` and `.zshrc` and deletes `~/.git-subcommands.rc`.

## Test

- `bash test/run.sh`
