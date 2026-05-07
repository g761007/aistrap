#!/usr/bin/env bash
# Phase 09 — Container / Kubernetes
# OrbStack (Docker Desktop replacement) + kubectl / helm / k9s.

step "Container & Kubernetes"

# ── OrbStack ──────────────────────────────────────────────────────────────────
if [[ -d "/Applications/OrbStack.app" ]]; then
  skip "OrbStack already installed"
else
  info "Installing OrbStack..."
  run brew install --cask orbstack
fi

# ── kubectl / helm / k9s (via Brewfile, verify here) ─────────────────────────
for _tool in kubectl helm k9s; do
  if has_command "$_tool"; then
    info "${_tool}: $(${_tool} version --client --short 2>/dev/null | head -1 || ${_tool} version 2>/dev/null | head -1 || echo 'ok')"
  else
    warn "${_tool}: not found — check Brewfile installation."
  fi
done

# ── kubectl completions ────────────────────────────────────────────────────────
if has_command kubectl; then
  append_marked "${HOME}/.zshrc" "kubectl" \
    'source <(kubectl completion zsh)
alias k=kubectl
compdef k=kubectl'
fi

info "Container & Kubernetes setup complete."
info "  Launch OrbStack.app to complete Docker/Kubernetes setup."
