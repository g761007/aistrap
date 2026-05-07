#!/usr/bin/env bash
# Phase 03 — Runtime management with mise
# Installs global runtimes: Python, Ruby, Node.js, Bun.

step "Runtime management (mise)"

# mise is installed via Brewfile (phase 01).
require_command mise "mise not found. Run phase 01 (homebrew) first."
has_command mise || return 0

info "mise $(mise --version)"

# Activate mise in the current shell so subsequent commands work.
eval "$(mise activate bash)"

# ── Install global runtimes ───────────────────────────────────────────────────
_install_runtime() {
  local name="$1" version="$2"
  local current
  current=$(mise current "$name" 2>/dev/null || true)
  if [[ -n "$current" && "$current" != "missing" ]]; then
    skip "mise runtime: ${name} ${current}"
  else
    info "Installing runtime: ${name}@${version}"
    run mise use --global "${name}@${version}"
  fi
}

_install_runtime "python" "latest"
_install_runtime "ruby"   "latest"
_install_runtime "node"   "lts"
_install_runtime "bun"    "latest"

# ── Shell integration ─────────────────────────────────────────────────────────
append_marked "${HOME}/.zshrc" "mise" 'eval "$(mise activate zsh)"'

info "Runtime setup complete."
info "  python : $(mise current python 2>/dev/null || echo 'pending')"
info "  ruby   : $(mise current ruby   2>/dev/null || echo 'pending')"
info "  node   : $(mise current node   2>/dev/null || echo 'pending')"
info "  bun    : $(mise current bun    2>/dev/null || echo 'pending')"
