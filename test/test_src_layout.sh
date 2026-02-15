#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/test_helpers.sh"

main() {
  local f
  for f in git-latest git-local-branch git-merged git-last; do
    if [[ ! -f "$REPO_ROOT/src/$f" ]]; then
      fail "missing src/$f"
    fi
    if [[ ! -x "$REPO_ROOT/src/$f" ]]; then
      fail "src/$f is not executable"
    fi
  done
}

main "$@"

