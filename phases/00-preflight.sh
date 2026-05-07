#!/usr/bin/env bash
# Phase 00 — Preflight checks
# Verifies macOS version, Xcode CLT, disk space, and caches sudo.

step "Preflight checks"

# macOS version ≥ 13 (Ventura)
macos_version_check 13

info "macOS $(sw_vers -productVersion) on $(detect_arch)"

# ── Xcode Command Line Tools ───────────────────────────────────────────────────
if xcode-select -p &>/dev/null; then
  info "Xcode CLT: $(xcode-select -p)"
else
  warn "Xcode Command Line Tools not found. Installing..."
  if ! is_dryrun; then
    xcode-select --install
    pause "Press Enter once the Xcode CLT installation dialog has completed..."
    xcode-select -p &>/dev/null || abort "Xcode CLT installation failed."
  fi
  info "Xcode CLT installed."
fi

# ── Disk space (require ≥ 20 GB free) ────────────────────────────────────────
_free_gb=$(df -g / | awk 'NR==2 {print $4}')
if (( _free_gb < 20 )); then
  abort "Less than 20 GB of free disk space (${_free_gb} GB). Free up space and re-run."
fi
info "Disk space: ${_free_gb} GB free"

# ── Cache sudo credentials and keep them alive ────────────────────────────────
if ! is_dryrun; then
  sudo -v
  # Refresh sudo timestamp in the background for the duration of the script.
  ( while true; do sudo -n true; sleep 60; done ) &
  _SUDO_KEEPER_PID=$!
  # Ensure the keeper is killed when the top-level script exits.
  # (install.sh sources phases, so this trap is set in the subshell context.)
  trap 'kill $_SUDO_KEEPER_PID 2>/dev/null' EXIT
fi

info "Preflight checks passed."
