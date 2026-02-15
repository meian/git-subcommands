#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/test_helpers.sh"

main() {
  local repo
  repo="$(make_temp_repo)"
  echo "second" >> "$repo/file.txt"
  git -C "$repo" add file.txt
  git -C "$repo" commit -q -m "second"
  echo "third" >> "$repo/file.txt"
  git -C "$repo" add file.txt
  git -C "$repo" commit -q -m "third"

  run_cmd "\"$REPO_ROOT/git-last\"" "$repo"
  assert_eq "0" "$CMD_EXIT_CODE" "git-last should succeed"
  assert_contains "$CMD_STDOUT" "third" "latest commit diff should be shown"

  run_cmd "\"$REPO_ROOT/git-last\" -1" "$repo"
  assert_eq "0" "$CMD_EXIT_CODE" "git-last -1 should succeed"
  assert_contains "$CMD_STDOUT" "second" "previous commit diff should be shown"

  run_cmd "\"$REPO_ROOT/git-last\" -0" "$repo"
  assert_eq "1" "$CMD_EXIT_CODE" "git-last -0 should fail"
  assert_contains "$CMD_STDERR" "Usage" "invalid argument should show usage"

  rm -rf "$repo"
}

main "$@"

