# git-worktree-sync

Automatically fast-forwards default branches in repositories with active linked worktrees.

## What it does

Scans `~/code/*/` (or `$CODE_DIR`) for repositories with active linked worktrees, fetches the default branch from the primary remote (`upstream` if present, otherwise `origin`), and fast-forwards only if the local branch is a strict ancestor of the remote. Repositories whose root checkout is on a non-default or detached branch are skipped, so a sync cannot move a feature-branch pointer. Diverged branches are skipped. Dirty default-branch checkouts are auto-stashed with a tagged message before reset.

## Requirements

- `git`

## Install

### Homebrew (recommended)

```sh
brew install athal7/tap/git-worktree-sync
```

### Manual

```sh
curl -sL https://github.com/athal7/git-worktree-sync/releases/latest/download/git-worktree-sync -o ~/.local/bin/git-worktree-sync
chmod +x ~/.local/bin/git-worktree-sync
```

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `CODE_DIR` | `~/code` | Directory to scan for git repos |

## Usage

```sh
git-worktree-sync
```

Run manually or schedule via a LaunchAgent to keep eligible default branches current.

## License

MIT
