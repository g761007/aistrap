#!/usr/bin/env bash
# Interactive confirmation helpers.

# ask_yes_no <prompt>
# Returns 0 (yes) or 1 (no).
# When BOOTSTRAP_YES=1, always returns 0 without prompting.
ask_yes_no() {
  local prompt="$1"
  if is_yes; then
    return 0
  fi
  local answer
  printf "${_BLD}%s [y/N] ${_RST}" "$prompt" >&2
  read -r answer
  [[ "${answer,,}" == "y" || "${answer,,}" == "yes" ]]
}

# confirm_phase <phase_name>
# Asks before running a phase. In --yes mode, auto-confirms.
confirm_phase() {
  local name="$1"
  if is_yes; then
    return 0
  fi
  printf "\n${_BLD}${_BLU}Phase: %s${_RST}\n" "$name" >&2
  ask_yes_no "  Run this phase?"
}

# pause <message>
# Pause and wait for the user to press Enter.
pause() {
  local msg="${1:-Press Enter to continue...}"
  printf "${_YLW}%s${_RST}" "$msg" >&2
  read -r _
}
