#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/test_helpers.sh"

main() {
  local repo
  repo="$(make_temp_repo)"
  git -C "$repo" checkout -q -b feature/merged
  echo "change" >> "$repo/file.txt"
  git -C "$repo" add file.txt
  git -C "$repo" commit -q -m "feature change"
  git -C "$repo" checkout -q main
  git -C "$repo" merge -q --no-ff feature/merged -m "merge feature"
  git -C "$repo" checkout -q -b feature/alive
  echo "alive" >> "$repo/file.txt"
  git -C "$repo" add file.txt
  git -C "$repo" commit -q -m "alive change"
  git -C "$repo" checkout -q main

  run_cmd "\"$REPO_ROOT/git-merged\"" "$repo"
  assert_eq "0" "$CMD_EXIT_CODE" "git-merged should succeed"
  assert_contains "$CMD_STDOUT" "feature/merged" "merged branch should be listed"

  run_cmd "\"$REPO_ROOT/git-merged\" -clean" "$repo"
  assert_eq "0" "$CMD_EXIT_CODE" "git-merged -clean should succeed"
  if git -C "$repo" show-ref --verify --quiet refs/heads/feature/merged; then
    fail "feature/merged should be deleted by -clean"
  fi
  if ! git -C "$repo" show-ref --verify --quiet refs/heads/feature/alive; then
    fail "feature/alive should remain"
  fi

  rm -rf "$repo"
}

main "$@"
