#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=./test_helpers.sh
source "$ROOT/test/test_helpers.sh"

make_source_repo() {
  local src
  src="$(mktemp -d)"
  mkdir -p "$src/src"
  cat > "$src/src/git-alpha" <<'SCRIPT'
#!/usr/bin/env bash
echo alpha
SCRIPT
  chmod +x "$src/src/git-alpha"

  cat > "$src/src/git-beta" <<'SCRIPT'
#!/usr/bin/env bash
echo beta
SCRIPT
  chmod +x "$src/src/git-beta"

  git -C "$src" init -q
  git -C "$src" config user.name "Test User"
  git -C "$src" config user.email "test@example.com"
  git -C "$src" config commit.gpgsign false
  git -C "$src" config tag.gpgSign false
  git -C "$src" add src/git-alpha src/git-beta
  git -C "$src" commit -q -m "initial"
  git -C "$src" branch -M main
  GIT_EDITOR=true git -C "$src" tag v1.0.0

  rm -f "$src/src/git-beta"
  cat > "$src/src/git-gamma" <<'SCRIPT'
#!/usr/bin/env bash
echo gamma
SCRIPT
  chmod +x "$src/src/git-gamma"
  git -C "$src" add src/git-beta src/git-gamma
  git -C "$src" commit -q -m "replace beta with gamma"
  GIT_EDITOR=true git -C "$src" tag v2.0.0

  git -C "$src" checkout -q -b feature
  rm -f "$src/src/git-gamma"
  cat > "$src/src/git-delta" <<'SCRIPT'
#!/usr/bin/env bash
echo delta
SCRIPT
  chmod +x "$src/src/git-delta"
  git -C "$src" add src/git-gamma src/git-delta
  git -C "$src" commit -q -m "feature branch delta"
  git -C "$src" checkout -q main

  echo "$src"
}

main() {
  local home src repo_url install_root rc_file bashrc zshrc
  home="$(mktemp -d)"
  src="$(make_source_repo)"
  trap "rm -rf '$home' '$src'" EXIT
  repo_url="file://$src"
  install_root="$home/.local/share/git-subcommands"
  rc_file="$home/.git-subcommands.rc"
  bashrc="$home/.bashrc"
  zshrc="$home/.zshrc"

  run_cmd "HOME='$home' GIT_SUBCOMMANDS_REPO_URL='$repo_url' '$ROOT/install.sh' --repo '$repo_url'" "$ROOT"
  [[ "$CMD_EXIT_CODE" -ne 0 ]] || fail "install should fail for unsupported --repo option"
  assert_contains "$CMD_STDERR" "unknown argument: --repo" "unsupported option error message"

  run_cmd "HOME='$home' GIT_SUBCOMMANDS_REPO_URL='$repo_url' '$ROOT/install.sh' --tag no-such-tag" "$ROOT"
  [[ "$CMD_EXIT_CODE" -ne 0 ]] || fail "install should fail for unknown tag"
  assert_contains "$CMD_STDERR" "was not found" "unknown tag error message"

  run_cmd "HOME='$home' GIT_SUBCOMMANDS_REPO_URL='$repo_url' '$ROOT/install.sh' --branch no-such-branch" "$ROOT"
  [[ "$CMD_EXIT_CODE" -ne 0 ]] || fail "install should fail for unknown branch"
  assert_contains "$CMD_STDERR" "was not found" "unknown branch error message"

  run_cmd "HOME='$home' GIT_SUBCOMMANDS_REPO_URL='$repo_url' '$ROOT/install.sh' --branch feature --tag v1.0.0" "$ROOT"
  [[ "$CMD_EXIT_CODE" -ne 0 ]] || fail "install should fail for conflicting --branch and --tag"
  assert_contains "$CMD_STDERR" "cannot be used together" "branch/tag conflict error message"

  mkdir -p "$home/dotfiles"
  printf 'export TEST_BASH=1\n' > "$home/dotfiles/bashrc"
  printf 'export TEST_ZSH=1\n' > "$home/dotfiles/zshrc"
  ln -sf "$home/dotfiles/bashrc" "$bashrc"
  ln -sf "$home/dotfiles/zshrc" "$zshrc"

  run_cmd "cat '$ROOT/install.sh' | HOME='$home' GIT_SUBCOMMANDS_REPO_URL='$repo_url' sh -s -- --tag v1.0.0" "$ROOT"
  assert_eq "0" "$CMD_EXIT_CODE" "install should succeed"

  [[ -d "$install_root/.git" ]] || fail "install root should be git repo"
  [[ -x "$install_root/src/git-alpha" ]] || fail "git-alpha should be executable in install root"
  [[ -x "$install_root/src/git-beta" ]] || fail "git-beta should be executable in install root"
  [[ -f "$rc_file" ]] || fail "rc file should be created"
  [[ -f "$bashrc" ]] || fail ".bashrc should be created"
  [[ -f "$zshrc" ]] || fail ".zshrc should be created"
  [[ -L "$bashrc" ]] || fail ".bashrc symlink should be preserved"
  [[ -L "$zshrc" ]] || fail ".zshrc symlink should be preserved"

  local rc_content bash_content zsh_content
  rc_content="$(cat "$rc_file")"
  bash_content="$(cat "$bashrc")"
  zsh_content="$(cat "$zshrc")"
  assert_contains "$rc_content" 'export PATH="$HOME/.local/share/git-subcommands/src:$PATH"' "rc should append src PATH"
  assert_contains "$bash_content" '. "$HOME/.git-subcommands.rc"' "bashrc source line"
  assert_contains "$zsh_content" '. "$HOME/.git-subcommands.rc"' "zshrc source line"

  run_cmd "HOME='$home' GIT_SUBCOMMANDS_REPO_URL='$repo_url' '$ROOT/install.sh' --tag v1.0.0" "$ROOT"
  assert_eq "0" "$CMD_EXIT_CODE" "same tag reinstall without --update should succeed as noop"
  assert_contains "$CMD_STDOUT" "already installed" "should explain noop"

  run_cmd "HOME='$home' GIT_SUBCOMMANDS_REPO_URL='$repo_url' '$ROOT/install.sh' --tag v2.0.0" "$ROOT"
  assert_eq "0" "$CMD_EXIT_CODE" "tag change should reinstall"
  [[ -x "$install_root/src/git-gamma" ]] || fail "git-gamma should exist after tag switch"
  if [[ -e "$install_root/src/git-beta" ]]; then
    fail "stale git-beta should be removed from install root"
  fi

  run_cmd "HOME='$home' GIT_SUBCOMMANDS_REPO_URL='$repo_url' '$ROOT/install.sh' --update" "$ROOT"
  assert_eq "0" "$CMD_EXIT_CODE" "--update should succeed"

  run_cmd "HOME='$home' GIT_SUBCOMMANDS_REPO_URL='$repo_url' '$ROOT/install.sh' --branch feature" "$ROOT"
  assert_eq "0" "$CMD_EXIT_CODE" "branch install should succeed"
  [[ -x "$install_root/src/git-delta" ]] || fail "git-delta should exist after branch install"
  if [[ -e "$install_root/src/git-gamma" ]]; then
    fail "stale git-gamma should be removed from install root"
  fi

  cat > "$src/src/git-epsilon" <<'SCRIPT'
#!/usr/bin/env bash
echo epsilon
SCRIPT
  chmod +x "$src/src/git-epsilon"
  git -C "$src" checkout -q feature
  git -C "$src" add src/git-epsilon
  git -C "$src" commit -q -m "feature update epsilon"
  git -C "$src" checkout -q main

  printf 'feature\n' > "$install_root/.install-ref"
  run_cmd "HOME='$home' GIT_SUBCOMMANDS_REPO_URL='$repo_url' '$ROOT/install.sh' --update" "$ROOT"
  assert_eq "0" "$CMD_EXIT_CODE" "--update should succeed on branch install"
  [[ -x "$install_root/src/git-delta" ]] || fail "git-delta should remain after --update"
  [[ -x "$install_root/src/git-epsilon" ]] || fail "git-epsilon should be fetched by branch --update"
  if [[ -e "$install_root/src/git-gamma" ]]; then
    fail "--update should not switch tracked ref from feature to main"
  fi

  run_cmd "cat '$ROOT/uninstall.sh' | HOME='$home' sh -s --" "$ROOT"
  assert_eq "0" "$CMD_EXIT_CODE" "uninstall should succeed"
  [[ ! -e "$install_root" ]] || fail "install root should be deleted"
  [[ ! -e "$rc_file" ]] || fail "rc file should be deleted"
  if grep -q 'git-subcommands' "$bashrc"; then
    fail "bashrc managed block should be removed"
  fi
  if grep -q 'git-subcommands' "$zshrc"; then
    fail "zshrc managed block should be removed"
  fi
  [[ -L "$bashrc" ]] || fail ".bashrc symlink should be preserved after uninstall"
  [[ -L "$zshrc" ]] || fail ".zshrc symlink should be preserved after uninstall"

  run_cmd "HOME='$home' '$ROOT/uninstall.sh'" "$ROOT"
  assert_eq "0" "$CMD_EXIT_CODE" "uninstall should be idempotent"
}

main "$@"
