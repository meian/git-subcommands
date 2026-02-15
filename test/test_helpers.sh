#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  echo "FAIL: $*" >&2
  return 1
}

assert_eq() {
  local expected="$1"
  local actual="$2"
  local message="${3:-}"
  if [[ "$expected" != "$actual" ]]; then
    fail "${message} expected='$expected' actual='$actual'"
  fi
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local message="${3:-}"
  if [[ "$haystack" != *"$needle"* ]]; then
    fail "${message} missing '$needle'"
  fi
}

make_temp_repo() {
  local dir
  dir="$(mktemp -d)"
  git -C "$dir" init -q
  git -C "$dir" config user.name "Test User"
  git -C "$dir" config user.email "test@example.com"
  git -C "$dir" config commit.gpgsign false
  echo "init" > "$dir/file.txt"
  git -C "$dir" add file.txt
  git -C "$dir" commit -q -m "initial"
  git -C "$dir" branch -M main
  echo "$dir"
}

make_remote_pair() {
  local base
  base="$(mktemp -d)"
  git -C "$base" init --bare -q remote.git

  local src
  src="$(mktemp -d)"
  git -C "$src" init -q
  git -C "$src" config user.name "Test User"
  git -C "$src" config user.email "test@example.com"
  git -C "$src" config commit.gpgsign false
  echo "v1" > "$src/file.txt"
  git -C "$src" add file.txt
  git -C "$src" commit -q -m "initial"
  git -C "$src" branch -M main
  git -C "$src" remote add origin "$base/remote.git"
  git -C "$src" push -q -u origin main
  git -C "$base/remote.git" symbolic-ref HEAD refs/heads/main

  local work
  work="$(mktemp -d)"
  git -C "$work" clone -q "$base/remote.git" repo
  git -C "$work/repo" config user.name "Test User"
  git -C "$work/repo" config user.email "test@example.com"
  git -C "$work/repo" config commit.gpgsign false
  git -C "$work/repo" checkout -q -b feature
  git -C "$work/repo" checkout -q main
  echo "$base $src $work/repo"
}

run_cmd() {
  local cmd="$1"
  local cwd="$2"
  local out err code
  out="$(mktemp)"
  err="$(mktemp)"
  (
    cd "$cwd"
    set +e
    eval "$cmd" >"$out" 2>"$err"
    echo $? >"$out.code"
  )
  code="$(cat "$out.code")"
  CMD_STDOUT="$(cat "$out")"
  CMD_STDERR="$(cat "$err")"
  CMD_EXIT_CODE="$code"
  rm -f "$out" "$err" "$out.code"
}
