# git-worktree-sync

Hard-resets repository root checkouts to the default branch from the primary remote when their HEAD differs.

## What it does

Scans `~/code/*/` (or `$CODE_DIR`) for repos with active linked worktrees, fetches the default branch from `upstream` when present or `origin` otherwise, then runs `git reset --hard` on the root checkout to that remote commit. It resets the branch currently checked out in the root—even if that is a feature branch or has diverged—and discards its local-only commits from that branch tip. Dirty tracked and untracked changes are stashed with a tagged message before reset; recover them with `git stash list` / `git stash apply`.

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

Run manually or schedule via a LaunchAgent to keep eligible root checkouts aligned to the remote default.

## License

MIT
