# git-worktree-sync

Automatically fast-forwards the default branch in all your git worktree repos when the remote has new commits.

## What it does

Scans `~/code/*/` (or `$CODE_DIR`) for repos with active worktrees, fetches the default branch from origin, and fast-forwards only if the local branch is a strict ancestor of the remote. Diverged branches (local commits not in origin) are always skipped. Dirty worktrees are auto-stashed with a tagged message before the reset.

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

Run manually or schedule via a LaunchAgent to keep all default branches current automatically.

## License

MIT
