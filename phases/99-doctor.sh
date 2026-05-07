#!/usr/bin/env bash
# Phase 99 — Bootstrap Doctor
# Health check: runs tools/bootstrap-doctor.sh.

step "Bootstrap Doctor"

_doctor="${BOOTSTRAP_ROOT}/tools/bootstrap-doctor.sh"

if [[ ! -f "$_doctor" ]]; then
  abort "bootstrap-doctor.sh not found at ${_doctor}"
fi

# Run doctor as a report — its exit code is informational, not a blocker.
bash "$_doctor" || true
