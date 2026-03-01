#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=./test_helpers.sh
source "$ROOT/test/test_helpers.sh"

README_EN="$(cat "$ROOT/README.md")"
README_JA="$(cat "$ROOT/README.ja.md")"
AGENTS="$(cat "$ROOT/AGENTS.md")"
SYNC_MAP_FILE="$ROOT/.sdd/specs/readme-ja-version/readme-sync-checklist.md"

assert_contains "$README_EN" "## Subcommands" "README.md sections"
assert_contains "$README_EN" "## Requirements" "README.md sections"
assert_contains "$README_EN" "## Setup" "README.md sections"
assert_contains "$README_EN" "## Test" "README.md sections"
assert_contains "$README_EN" "[README.ja.md](README.ja.md)" "README.md mutual link"

assert_contains "$README_JA" "## サブコマンド" "README.ja.md sections"
assert_contains "$README_JA" "## 必要要件" "README.ja.md sections"
assert_contains "$README_JA" "## セットアップ" "README.ja.md sections"
assert_contains "$README_JA" "## テスト" "README.ja.md sections"
assert_contains "$README_JA" "[README.md](README.md)" "README.ja.md mutual link"

assert_contains "$AGENTS" "README.md" "AGENTS sync rule"
assert_contains "$AGENTS" "README.ja.md" "AGENTS sync rule"
assert_contains "$AGENTS" "同時に更新" "AGENTS sync rule"

if [[ ! -f "$SYNC_MAP_FILE" ]]; then
  fail "sync checklist file missing: $SYNC_MAP_FILE"
fi

SYNC_MAP="$(cat "$SYNC_MAP_FILE")"
assert_contains "$SYNC_MAP" "overview" "sync checklist sections"
assert_contains "$SYNC_MAP" "subcommands" "sync checklist sections"
assert_contains "$SYNC_MAP" "requirements" "sync checklist sections"
assert_contains "$SYNC_MAP" "setup" "sync checklist sections"
assert_contains "$SYNC_MAP" "test" "sync checklist sections"

echo "PASS"
