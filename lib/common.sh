#!/usr/bin/env bash
set -euo pipefail

die() {
  echo "Error: $*" >&2
  exit 1
}

usage_error() {
  local usage="$1"
  echo "Usage: $usage" >&2
  exit 1
}

require_command() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || die "required command '$cmd' is not installed"
}

git_list_local_branches() {
  local pattern="${1:-}"
  local branches
  branches="$(git for-each-ref --format='%(refname:short)' refs/heads)"
  if [[ -n "$pattern" ]]; then
    branches="$(printf '%s\n' "$branches" | grep -F -- "$pattern" || true)"
  fi
  printf '%s\n' "$branches" | sed '/^$/d'
}

git_current_branch() {
  git branch --show-current
}

git_list_merged_branches() {
  local current
  current="$(git_current_branch)"
  git for-each-ref --format='%(refname:short)' --merged HEAD refs/heads \
    | grep -F -x -v -- "$current" || true
}

parse_last_offset() {
  local arg="${1:-}"
  if [[ -z "$arg" ]]; then
    echo "0"
    return 0
  fi
  if [[ "$arg" =~ ^-[1-9][0-9]*$ ]]; then
    echo "${arg#-}"
    return 0
  fi
  return 1
}

