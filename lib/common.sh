#!/usr/bin/env bash
# Common logging, utilities, and dry-run support.

# ── Color setup ──────────────────────────────────────────────────────────────
if [[ -t 1 ]] && [[ -z "${NO_COLOR:-}" ]]; then
  _RED='\033[0;31m'
  _GRN='\033[0;32m'
  _YLW='\033[0;33m'
  _BLU='\033[0;34m'
  _CYN='\033[0;36m'
  _BLD='\033[1m'
  _RST='\033[0m'
else
  _RED='' _GRN='' _YLW='' _BLU='' _CYN='' _BLD='' _RST=''
fi

# ── Logging ───────────────────────────────────────────────────────────────────
log()  { printf "${_RST}%s\n"          "$*" >&2; }
info() { printf "${_GRN}  ✓${_RST} %s\n" "$*" >&2; }
warn() { printf "${_YLW}  ⚠${_RST} %s\n" "$*" >&2; }
err()  { printf "${_RED}  ✗${_RST} %s\n" "$*" >&2; }
step() { printf "\n${_BLD}${_BLU}▶ %s${_RST}\n" "$*" >&2; }
skip() { printf "${_CYN}  ↩${_RST} %s (already done)\n" "$*" >&2; }

# ── Core helpers ──────────────────────────────────────────────────────────────
has_command() { command -v "$1" >/dev/null 2>&1; }

ensure_dir() {
  local d="$1"
  [[ -d "$d" ]] && return 0
  run mkdir -p "$d"
}

# run <cmd> [args…]
# In dry-run mode: prints the command instead of executing it.
run() {
  if is_dryrun; then
    printf "${_YLW}  [dry-run]${_RST} %s\n" "$*" >&2
  else
    "$@"
  fi
}

is_dryrun() { [[ "${BOOTSTRAP_DRY_RUN:-0}" == "1" ]]; }
is_yes()    { [[ "${BOOTSTRAP_YES:-0}"      == "1" ]]; }

# abort <message>
abort() { err "$*"; exit 1; }

# require_command <cmd> [message]
# In normal mode: aborts if <cmd> is not found.
# In dry-run mode: warns and returns 0 so the phase can continue showing
# what it would do even when prerequisites aren't installed yet.
require_command() {
  local cmd="$1" msg="${2:-}"
  if ! has_command "$cmd"; then
    if is_dryrun; then
      warn "${cmd}: not installed yet (will be provided by an earlier phase)"
      return 0
    else
      abort "${msg:-${cmd} not found. Ensure the previous phases completed successfully.}"
    fi
  fi
}
