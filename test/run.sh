#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

failed=0
for t in test/test_*.sh; do
  if [[ "$t" == "test/test_helpers.sh" ]]; then
    continue
  fi
  echo "Running $t"
  if ! bash "$t"; then
    failed=1
    echo "FAILED: $t"
  fi
done

if [[ "$failed" -ne 0 ]]; then
  exit 1
fi

echo "All tests passed"
