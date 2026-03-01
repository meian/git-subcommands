#!/usr/bin/env sh
set -eu

INSTALL_ROOT="${HOME}/.local/share/git-subcommands"
RC_FILE="${HOME}/.git-subcommands.rc"
REF_FILE="${INSTALL_ROOT}/.install-ref"
REPO_URL="${GIT_SUBCOMMANDS_REPO_URL:-https://github.com/meian/git-subcommands.git}"
DEFAULT_REF="${GIT_SUBCOMMANDS_DEFAULT_REF:-main}"
PROFILE_BEGIN="# >>> git-subcommands >>>"
PROFILE_END="# <<< git-subcommands <<<"
TMP_ROOT=""

usage() {
  cat <<USAGE
Usage: install.sh [--update] [--branch <branch>] [--tag <tag>]
USAGE
}

die() {
  echo "Error: $*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "required command '$1' is not installed"
}

cleanup_tmp() {
  if [ -n "$TMP_ROOT" ] && [ -d "$TMP_ROOT" ]; then
    rm -rf "$TMP_ROOT"
  fi
}

parse_args() {
  UPDATE=0
  BRANCH=""
  TAG=""
  USER_SPECIFIED_REF=0

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --update)
        UPDATE=1
        shift
        ;;
      --tag)
        [ "$#" -ge 2 ] || die "--tag requires a value"
        TAG="$2"
        USER_SPECIFIED_REF=1
        shift 2
        ;;
      --branch)
        [ "$#" -ge 2 ] || die "--branch requires a value"
        BRANCH="$2"
        USER_SPECIFIED_REF=1
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        usage >&2
        die "unknown argument: $1"
        ;;
    esac
  done

  if [ -n "$BRANCH" ] && [ -n "$TAG" ]; then
    die "--branch and --tag cannot be used together"
  fi

  if [ -n "$TAG" ]; then
    REQUESTED_REF="$TAG"
    REF_KIND="tag"
  elif [ -n "$BRANCH" ]; then
    REQUESTED_REF="$BRANCH"
    REF_KIND="branch"
  else
    REQUESTED_REF="$DEFAULT_REF"
    REF_KIND="default_branch"
  fi
}

apply_state_key_ref() {
  case "$CURRENT_STATE_KEY" in
    tag:*)
      REQUESTED_REF="${CURRENT_STATE_KEY#tag:}"
      REF_KIND="tag"
      ;;
    branch:*)
      REQUESTED_REF="${CURRENT_STATE_KEY#branch:}"
      REF_KIND="branch"
      ;;
    default_branch:*)
      REQUESTED_REF="${CURRENT_STATE_KEY#default_branch:}"
      REF_KIND="default_branch"
      ;;
    legacy:*)
      REQUESTED_REF="${CURRENT_STATE_KEY#legacy:}"
      REF_KIND="branch"
      ;;
    *)
      return 1
      ;;
  esac

  [ -n "$REQUESTED_REF" ] || return 1
  return 0
}

apply_installed_checkout_ref() {
  current_branch=""
  current_tag=""

  if current_branch="$(git -C "$INSTALL_ROOT" symbolic-ref --quiet --short HEAD 2>/dev/null)"; then
    REQUESTED_REF="$current_branch"
    REF_KIND="branch"
    return 0
  fi

  if current_tag="$(git -C "$INSTALL_ROOT" describe --tags --exact-match 2>/dev/null)"; then
    REQUESTED_REF="$current_tag"
    REF_KIND="tag"
    return 0
  fi

  return 1
}

validate_requested_ref() {
  remote_ref=""
  ls_output=""

  case "$REF_KIND" in
    tag)
      remote_ref="refs/tags/${REQUESTED_REF}"
      if ! ls_output="$(git ls-remote --refs --tags "$REPO_URL" "$remote_ref" 2>/dev/null)"; then
        die "tag '${REQUESTED_REF}' was not found in '${REPO_URL}'"
      fi
      REQUESTED_REVISION="$(printf '%s\n' "$ls_output" | awk 'NR==1 {print $1}')"
      [ -n "$REQUESTED_REVISION" ] || die "tag '${REQUESTED_REF}' was not found in '${REPO_URL}'"
      ;;
    branch|default_branch)
      remote_ref="refs/heads/${REQUESTED_REF}"
      if ! ls_output="$(git ls-remote --refs --heads "$REPO_URL" "$remote_ref" 2>/dev/null)"; then
        die "branch '${REQUESTED_REF}' was not found in '${REPO_URL}'"
      fi
      REQUESTED_REVISION="$(printf '%s\n' "$ls_output" | awk 'NR==1 {print $1}')"
      [ -n "$REQUESTED_REVISION" ] || die "branch '${REQUESTED_REF}' was not found in '${REPO_URL}'"
      ;;
    *)
      die "unsupported ref kind: ${REF_KIND}"
      ;;
  esac
}

read_current_state() {
  CURRENT_STATE_KEY=""
  CURRENT_REVISION=""
  [ -f "$REF_FILE" ] || return 0

  if grep -q '^state_key=' "$REF_FILE"; then
    CURRENT_STATE_KEY="$(awk -F= '/^state_key=/{print $2}' "$REF_FILE" | tail -n1)"
    CURRENT_REVISION="$(awk -F= '/^revision=/{print $2}' "$REF_FILE" | tail -n1)"
  else
    legacy_ref="$(head -n1 "$REF_FILE")"
    CURRENT_STATE_KEY="legacy:${legacy_ref}"
  fi
}

write_state_file() {
  {
    printf 'state_key=%s\n' "$REQUESTED_STATE_KEY"
    printf 'revision=%s\n' "$REQUESTED_REVISION"
  } > "$REF_FILE"
}

remove_managed_block() {
  profile_file="$1"
  tmp="$(mktemp)"

  awk -v b="$PROFILE_BEGIN" -v e="$PROFILE_END" '
    $0 == b {skip=1; next}
    $0 == e {skip=0; next}
    skip != 1 {print}
  ' "$profile_file" > "$tmp"

  cat "$tmp" > "$profile_file"
  rm -f "$tmp"
}

ensure_profile_block() {
  profile_file="$1"
  mkdir -p "$(dirname "$profile_file")"
  touch "$profile_file"
  remove_managed_block "$profile_file"

  {
    echo "$PROFILE_BEGIN"
    echo 'if [ -f "$HOME/.git-subcommands.rc" ]; then'
    echo '  . "$HOME/.git-subcommands.rc"'
    echo 'fi'
    echo "$PROFILE_END"
  } >> "$profile_file"
}

write_rc_file() {
  cat > "$RC_FILE" <<'RCFILE'
# Managed by git-subcommands installer.
case ":$PATH:" in
  *":$HOME/.local/share/git-subcommands/src:"*) ;;
  *) export PATH="$HOME/.local/share/git-subcommands/src:$PATH" ;;
esac
RCFILE
}

clone_requested_ref() {
  TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/git-subcommands.XXXXXX")"
  trap cleanup_tmp EXIT INT TERM

  git clone --depth 1 --branch "$REQUESTED_REF" "$REPO_URL" "$TMP_ROOT" >/dev/null 2>&1 \
    || die "failed to clone '${REPO_URL}' with ref '${REQUESTED_REF}'"

  rm -rf "$INSTALL_ROOT"
  mkdir -p "$(dirname "$INSTALL_ROOT")"
  mv "$TMP_ROOT" "$INSTALL_ROOT"
  TMP_ROOT=""

  write_state_file
}

update_requested_branch_in_place() {
  if ! git -C "$INSTALL_ROOT" remote set-url origin "$REPO_URL" >/dev/null 2>&1; then
    die "failed to set remote 'origin' to '${REPO_URL}'"
  fi

  if git -C "$INSTALL_ROOT" show-ref --verify --quiet "refs/heads/${REQUESTED_REF}"; then
    git -C "$INSTALL_ROOT" checkout -q "$REQUESTED_REF" >/dev/null 2>&1 \
      || die "failed to checkout local branch '${REQUESTED_REF}'"
  else
    git -C "$INSTALL_ROOT" fetch origin "$REQUESTED_REF" >/dev/null 2>&1 \
      || die "failed to fetch branch '${REQUESTED_REF}' from '${REPO_URL}'"
    git -C "$INSTALL_ROOT" checkout -q -b "$REQUESTED_REF" --track "origin/${REQUESTED_REF}" >/dev/null 2>&1 \
      || die "failed to create local tracking branch '${REQUESTED_REF}'"
  fi

  git -C "$INSTALL_ROOT" pull --ff-only >/dev/null 2>&1 \
    || die "failed to fast-forward branch '${REQUESTED_REF}'"

  REQUESTED_REVISION="$(git -C "$INSTALL_ROOT" rev-parse HEAD 2>/dev/null || true)"
  [ -n "$REQUESTED_REVISION" ] || die "failed to resolve installed revision"
  write_state_file
}

main() {
  require_command git
  parse_args "$@"

  already_installed=0
  needs_refresh=1

  if [ -d "$INSTALL_ROOT/.git" ]; then
    already_installed=1
    read_current_state
    if [ "$UPDATE" -eq 1 ] && [ "$USER_SPECIFIED_REF" -eq 0 ]; then
      apply_installed_checkout_ref || apply_state_key_ref || true
    fi
  fi

  REQUESTED_STATE_KEY="${REF_KIND}:${REQUESTED_REF}"
  validate_requested_ref

  if [ "$already_installed" -eq 1 ]; then
    if [ "$CURRENT_STATE_KEY" = "$REQUESTED_STATE_KEY" ] && [ "$UPDATE" -eq 0 ]; then
      needs_refresh=0
    fi
  fi

  if [ "$needs_refresh" -eq 0 ]; then
    echo "git-subcommands is already installed with ref '${REQUESTED_REF}'."
  else
    use_in_place_branch_update=0
    if [ "$already_installed" -eq 1 ] && [ "$UPDATE" -eq 1 ] && [ "$USER_SPECIFIED_REF" -eq 0 ]; then
      case "$REF_KIND" in
        branch|default_branch)
          use_in_place_branch_update=1
          ;;
      esac
    fi

    if [ "$use_in_place_branch_update" -eq 1 ]; then
      update_requested_branch_in_place
    else
      clone_requested_ref
    fi

    if [ "$already_installed" -eq 1 ]; then
      echo "Updated git-subcommands to ref '${REQUESTED_REF}'."
    else
      echo "Installed git-subcommands with ref '${REQUESTED_REF}'."
    fi
  fi

  write_rc_file
  ensure_profile_block "${HOME}/.bashrc"
  ensure_profile_block "${HOME}/.zshrc"

  echo "Installation complete. Run 'source ~/.git-subcommands.rc' or restart your shell."
}

main "$@"
