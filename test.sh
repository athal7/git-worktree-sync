#!/bin/sh
set -eu

root=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
script="$root/git-worktree-sync"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

export HOME="$tmp/home"
export CODE_DIR="$tmp/code"
mkdir -p "$HOME" "$CODE_DIR" "$tmp/remotes" "$tmp/seed" "$tmp/worktrees"
git config --global user.name 'Sync Tool Test'
git config --global user.email 'sync-tool-test@example.invalid'

make_repo() {
  name=$1
  origin="$tmp/remotes/$name.git"
  seed="$tmp/seed/$name"
  repo="$CODE_DIR/$name"
  git init -q --bare --initial-branch=main "$origin"
  git init -q --initial-branch=main "$seed"
  printf 'initial\n' > "$seed/file"
  git -C "$seed" add file
  git -C "$seed" commit -q -m initial
  git -C "$seed" remote add origin "$origin"
  git -C "$seed" push -q -u origin main
  git --git-dir="$origin" symbolic-ref HEAD refs/heads/main
  git clone -q "$origin" "$repo"
}

advance_remote() {
  name=$1
  origin="$tmp/remotes/$name.git"
  updater="$tmp/updater-$name"
  git clone -q "$origin" "$updater"
  git -C "$updater" commit -q --allow-empty -m advance
  git -C "$updater" push -q origin main
}

"$script" --help > "$tmp/help"
grep -q 'Hard-resets the checked-out root' "$tmp/help"

# Even a diverged feature branch at the root is reset to the selected remote default.
make_repo feature-root
feature_repo="$CODE_DIR/feature-root"
git -C "$feature_repo" switch -q -c feature
printf 'local feature commit\n' >> "$feature_repo/file"
git -C "$feature_repo" add file
git -C "$feature_repo" commit -q -m 'feature-only commit'
local_feature=$(git -C "$feature_repo" rev-parse HEAD)
git -C "$feature_repo" worktree add -q -b linked-worktree "$tmp/worktrees/feature-root" main
advance_remote feature-root
# Keep the local default branch already aligned, reproducing the previous skip condition.
git -C "$tmp/worktrees/feature-root" fetch -q origin main
git -C "$tmp/worktrees/feature-root" reset --hard -q origin/main
printf 'untracked local change\n' > "$feature_repo/local.txt"
"$script" > "$tmp/feature-output"
[ "$(git -C "$feature_repo" symbolic-ref --short HEAD)" = feature ]
[ "$(git -C "$feature_repo" rev-parse HEAD)" = "$(git -C "$feature_repo" rev-parse refs/remotes/origin/main)" ]
[ "$(git -C "$feature_repo" rev-parse HEAD)" != "$local_feature" ]
[ ! -e "$feature_repo/local.txt" ]
git -C "$feature_repo" stash list | grep -q 'git-worktree-sync auto-stash'
grep -q 'feature had local mods, stashed before hard-reset to origin/main' "$tmp/feature-output"

# The standard default-branch root remains synchronized too.
make_repo default-root
default_repo="$CODE_DIR/default-root"
git -C "$default_repo" worktree add -q -b linked-worktree "$tmp/worktrees/default-root" main
advance_remote default-root
"$script" > "$tmp/default-output"
[ "$(git -C "$default_repo" rev-parse HEAD)" = "$(git -C "$default_repo" rev-parse refs/remotes/origin/main)" ]
grep -q 'main hard-reset to origin/main' "$tmp/default-output"

printf 'sync hard-reset tests passed\n'
