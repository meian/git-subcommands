#!/usr/bin/env sh
set -eu

INSTALL_ROOT="${HOME}/.local/share/git-subcommands"
RC_FILE="${HOME}/.git-subcommands.rc"
PROFILE_BEGIN="# >>> git-subcommands >>>"
PROFILE_END="# <<< git-subcommands <<<"

remove_managed_block() {
  profile_file="$1"

  [ -f "$profile_file" ] || return 0

  tmp="$(mktemp)"
  awk -v b="$PROFILE_BEGIN" -v e="$PROFILE_END" '
    $0 == b {skip=1; next}
    $0 == e {skip=0; next}
    skip != 1 {print}
  ' "$profile_file" > "$tmp"

  cat "$tmp" > "$profile_file"
  rm -f "$tmp"
}

main() {
  rm -rf "$INSTALL_ROOT"
  rm -f "$RC_FILE"

  remove_managed_block "${HOME}/.bashrc"
  remove_managed_block "${HOME}/.zshrc"

  echo "Uninstall complete. Restart your shell if it is already running."
}

main "$@"
