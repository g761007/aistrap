#!/usr/bin/env bash
# Mac AI Developer Workstation Bootstrap
# Usage: ./install.sh [--yes] [--dry-run] [--phase=N|N..M] [--skip=N,M] [--doctor]
set -euo pipefail

BOOTSTRAP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export BOOTSTRAP_ROOT
export BACKUP_ROOT="${HOME}/.bootstrap-backup/$(date +%Y%m%d-%H%M%S)"

# Source all lib helpers first (order matters: common before others).
for _lib in common machine backup append confirm; do
  # shellcheck source=/dev/null
  source "${BOOTSTRAP_ROOT}/lib/${_lib}.sh"
done

# ── Flag parsing ──────────────────────────────────────────────────────────────
BOOTSTRAP_DRY_RUN=0
BOOTSTRAP_YES=0
export BOOTSTRAP_DRY_RUN BOOTSTRAP_YES

_phase_filter=""   # empty = all; "04" = only 04; "01..06" = range
_skip_phases=""    # comma-separated phase numbers to skip
_doctor_only=0

for _arg in "$@"; do
  case "$_arg" in
    --dry-run)        BOOTSTRAP_DRY_RUN=1 ;;
    --yes|-y)         BOOTSTRAP_YES=1 ;;
    --doctor)         _doctor_only=1 ;;
    --phase=*)        _phase_filter="${_arg#--phase=}" ;;
    --skip=*)         _skip_phases="${_arg#--skip=}" ;;
    --help|-h)
      cat <<'EOF'
Usage: ./install.sh [options]

Options:
  --yes            Non-interactive; auto-confirm all prompts
  --dry-run        Print actions without executing
  --phase=N        Run only phase N (e.g. --phase=04)
  --phase=N..M     Run phases N through M (e.g. --phase=01..06)
  --skip=N,M,...   Skip listed phase numbers (e.g. --skip=09,12)
  --doctor         Run the health-check phase (99) only
  --help           Show this message
EOF
      exit 0 ;;
    *)
      warn "Unknown option: ${_arg}"; exit 1 ;;
  esac
done

# ── Banner ────────────────────────────────────────────────────────────────────
printf "\n${_BLD}${_BLU}╔══════════════════════════════════════════════╗${_RST}\n"
printf   "${_BLD}${_BLU}║  Mac AI Developer Workstation Bootstrap v1   ║${_RST}\n"
printf   "${_BLD}${_BLU}╚══════════════════════════════════════════════╝${_RST}\n\n"
log "  Arch   : $(detect_arch)"
log "  macOS  : $(sw_vers -productVersion)"
log "  Backups: ${BACKUP_ROOT}"
is_dryrun && warn "  DRY-RUN mode — no changes will be made"
printf '\n'

# ── Phase resolution ──────────────────────────────────────────────────────────
# Collect all phase scripts sorted by their numeric prefix.
_all_phases=()
while IFS= read -r -d '' f; do
  _all_phases+=("$f")
done < <(find "${BOOTSTRAP_ROOT}/phases" -maxdepth 1 -name '[0-9][0-9]-*.sh' -print0 | sort -z)

if [[ $_doctor_only == 1 ]]; then
  _phase_filter="99"
fi

# Returns 0 if a phase file should be run given current filters.
_phase_enabled() {
  local filepath="$1"
  local num
  num=$(basename "$filepath" | cut -c1-2)

  # --skip check
  if [[ -n "$_skip_phases" ]]; then
    IFS=',' read -ra _skips <<< "$_skip_phases"
    for s in "${_skips[@]}"; do
      [[ "$num" == "$s" ]] && return 1
    done
  fi

  # --phase filter
  if [[ -z "$_phase_filter" ]]; then
    return 0
  fi

  if [[ "$_phase_filter" == *..* ]]; then
    local lo hi
    lo="${_phase_filter%%.*}"
    hi="${_phase_filter##*.}"
    (( 10#$num >= 10#$lo && 10#$num <= 10#$hi )) && return 0 || return 1
  else
    [[ "$num" == "$_phase_filter" ]] && return 0 || return 1
  fi
}

# ── Phase execution ───────────────────────────────────────────────────────────
_run_phase() {
  local script="$1"
  local name
  name=$(basename "$script" .sh)

  step "Phase ${name}"

  # In interactive mode, ask before each phase (except preflight and doctor).
  local num
  num=$(echo "$name" | cut -c1-2)
  if [[ "$num" != "00" && "$num" != "99" ]]; then
    confirm_phase "$name" || { log "  Skipped."; return 0; }
  fi

  # Run the phase in a subshell so set -e is isolated.
  (
    set -euo pipefail
    # Re-source libs so the phase has access.
    for _lib in common machine backup append confirm; do
      source "${BOOTSTRAP_ROOT}/lib/${_lib}.sh"
    done
    source "$script"
  ) || {
    err "Phase ${name} failed. Backups are at: ${BACKUP_ROOT}"
    exit 1
  }
}

_phases_to_run=()
for _f in "${_all_phases[@]}"; do
  _phase_enabled "$_f" && _phases_to_run+=("$_f")
done

if [[ ${#_phases_to_run[@]} -eq 0 ]]; then
  warn "No phases matched the given filter."
  exit 0
fi

for _phase in "${_phases_to_run[@]}"; do
  _run_phase "$_phase"
done

# ── Done ──────────────────────────────────────────────────────────────────────
printf "\n${_BLD}${_GRN}✅  Bootstrap complete!${_RST}\n"
log "   Backups saved to: ${BACKUP_ROOT}"
log "   Run './install.sh --doctor' any time to re-check your setup."
