#!/usr/bin/env bash
# Phase 08 — Node.js ecosystem (pnpm via corepack, bun)

step "Node.js ecosystem"

# Ensure mise-managed Node is active.
if has_command mise; then
  eval "$(mise activate bash)" 2>/dev/null || true
fi

require_command node "Node.js not found. Run phase 03 (runtime) first."
has_command node || return 0
info "Node: $(node --version)"

# ── pnpm via corepack ─────────────────────────────────────────────────────────
if ! has_command corepack; then
  warn "corepack not found — skipping pnpm setup."
else
  if ! has_command pnpm; then
    info "Enabling corepack and preparing pnpm..."
    run corepack enable
    run corepack prepare pnpm@latest --activate
  else
    skip "pnpm already installed: $(pnpm --version)"
  fi
fi

# ── bun (via mise) ────────────────────────────────────────────────────────────
if has_command bun; then
  skip "bun already installed: $(bun --version)"
else
  if has_command mise; then
    info "Installing bun via mise..."
    run mise use --global bun@latest
    eval "$(mise activate bash)" 2>/dev/null || true
  else
    warn "bun not found and mise unavailable — skipping."
  fi
fi

# ── Shell integration ─────────────────────────────────────────────────────────
# pnpm needs its bin directory on PATH.
if has_command pnpm; then
  _pnpm_home=$(pnpm store path 2>/dev/null | sed 's|/store||' || true)
  if [[ -n "$_pnpm_home" ]]; then
    append_marked "${HOME}/.zshrc" "pnpm" \
      "export PNPM_HOME=\"${_pnpm_home}\"
export PATH=\"\${PNPM_HOME}:\${PATH}\""
  fi
fi

info "Node.js ecosystem setup complete."
has_command node   && info "  node  : $(node --version)"
has_command pnpm   && info "  pnpm  : $(pnpm --version)"
has_command bun    && info "  bun   : $(bun --version)"
