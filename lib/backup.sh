#!/usr/bin/env bash
# Safe backup helpers. All writes during a bootstrap session share one
# BACKUP_ROOT, which install.sh sets before sourcing the phase scripts.

# install.sh exports BACKUP_ROOT; fall back to a sensible default when
# sourced standalone (e.g., for testing).
: "${BACKUP_ROOT:=${HOME}/.bootstrap-backup/standalone-$(date +%Y%m%d-%H%M%S)}"

# backup_file <path>
# Copies the file to BACKUP_ROOT, preserving its structure.
# Safe to call on a path that does not exist (no-op).
backup_file() {
  local src="$1"
  [[ -e "$src" ]] || return 0

  local rel="${src#${HOME}/}"     # strip leading $HOME/
  rel="${rel//\//__}"             # replace / with __
  local dst="${BACKUP_ROOT}/${rel}"

  if is_dryrun; then
    printf "${_YLW}  [dry-run]${_RST} backup %s -> %s\n" "$src" "$dst" >&2
    return 0
  fi

  mkdir -p "${BACKUP_ROOT}"
  cp -a "$src" "$dst"
  info "backed up: ${src} → ${BACKUP_ROOT}/${rel}"
}

# backup_dir <path>
# Archives a directory into BACKUP_ROOT as a .tar.gz.
backup_dir() {
  local src="$1"
  [[ -d "$src" ]] || return 0

  local name
  name="$(basename "$src").$(date +%H%M%S).tar.gz"
  local dst="${BACKUP_ROOT}/${name}"

  if is_dryrun; then
    printf "${_YLW}  [dry-run]${_RST} backup dir %s -> %s\n" "$src" "$dst" >&2
    return 0
  fi

  mkdir -p "${BACKUP_ROOT}"
  tar -czf "$dst" -C "$(dirname "$src")" "$(basename "$src")"
  info "backed up dir: ${src} → ${dst}"
}
