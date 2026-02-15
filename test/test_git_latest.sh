#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/test_helpers.sh"

main() {
  local pair base src repo
  pair="$(make_remote_pair)"
  base="$(awk '{print $1}' <<<"$pair")"
  src="$(awk '{print $2}' <<<"$pair")"
  repo="$(awk '{print $3}' <<<"$pair")"

  echo "v2" > "$src/file.txt"
  git -C "$src" add file.txt
  git -C "$src" commit -q -m "update remote"
  git -C "$src" push -q origin main

  git -C "$repo" checkout -q feature

  run_cmd "\"$REPO_ROOT/git-latest\" main" "$repo"
  assert_eq "0" "$CMD_EXIT_CODE" "git-latest should succeed"

  local head_branch
  head_branch="$(git -C "$repo" branch --show-current)"
  assert_eq "main" "$head_branch" "should switch to target branch"

  local local_head remote_head
  local_head="$(git -C "$repo" rev-parse main)"
  remote_head="$(git -C "$repo" rev-parse origin/main)"
  assert_eq "$remote_head" "$local_head" "local branch should be updated to remote"

  run_cmd "git switch -q -" "$repo"
  assert_eq "0" "$CMD_EXIT_CODE" "switch back should work"
  head_branch="$(git -C "$repo" branch --show-current)"
  assert_eq "feature" "$head_branch" "should be able to return previous branch"

  rm -rf "$base" "$src" "$(dirname "$repo")"
}

main "$@"

