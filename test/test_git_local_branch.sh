#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/test_helpers.sh"

main() {
  local repo
  repo="$(make_temp_repo)"
  git -C "$repo" checkout -q -b feature/one
  git -C "$repo" checkout -q -b bugfix/two
  git -C "$repo" checkout -q main

  local fakebin
  fakebin="$(mktemp -d)"
  cat > "$fakebin/fzf" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
head -n 1
EOF
  chmod +x "$fakebin/fzf"

  run_cmd "PATH=\"$fakebin:$PATH\" \"$REPO_ROOT/git-local-branch\" feature" "$repo"
  assert_eq "0" "$CMD_EXIT_CODE" "git-local-branch should succeed with fzf"
  local head_branch
  head_branch="$(git -C "$repo" branch --show-current)"
  assert_eq "feature/one" "$head_branch" "should checkout selected filtered branch"

  run_cmd "PATH=\"/usr/bin:/bin\" \"$REPO_ROOT/git-local-branch\"" "$repo"
  assert_eq "1" "$CMD_EXIT_CODE" "missing fzf should fail"
  assert_contains "$CMD_STDERR" "fzf" "missing dependency message should mention fzf"

  rm -rf "$repo" "$fakebin"
}

main "$@"
