#!/usr/bin/env bash
# Phase 15 — SSH, GPG, and secrets setup
# Only generates an SSH key if none exists. Never overwrites existing keys.

step "Security & credentials"

# ── SSH key ───────────────────────────────────────────────────────────────────
info "Checking SSH keys..."
if ls "${HOME}/.ssh/id_"* &>/dev/null 2>&1; then
  info "Existing SSH keys found:"
  ls "${HOME}/.ssh/id_"* 2>/dev/null | grep -v '\.pub' | while read -r k; do
    info "  ${k}"
  done
  skip "SSH key generation (existing keys detected)"
else
  _email=$(git config --global user.email 2>/dev/null || echo "")
  if [[ -z "$_email" ]]; then
    warn "git user.email not set. Using placeholder for SSH key comment."
    _email="user@$(hostname)"
  fi
  info "Generating ed25519 SSH key for: ${_email}"
  run ssh-keygen -t ed25519 -C "$_email" -f "${HOME}/.ssh/id_ed25519" -N ""
  info "SSH key created: ${HOME}/.ssh/id_ed25519"
fi

# ── SSH agent + Keychain ──────────────────────────────────────────────────────
if ! is_dryrun; then
  eval "$(ssh-agent -s)" &>/dev/null || true
  # Add all id_* keys to the agent, storing passphrases in macOS Keychain.
  for _key in "${HOME}/.ssh/id_"*; do
    [[ "$_key" == *.pub ]] && continue
    ssh-add --apple-use-keychain "$_key" 2>/dev/null || \
      ssh-add "$_key" 2>/dev/null || true
  done
fi
info "SSH keys loaded into agent."

# ── SSH config ────────────────────────────────────────────────────────────────
# ~/.ssh/config is managed by phase 13 (chezmoi). No fallback written here
# to avoid two divergent sources of truth.
info "~/.ssh/config is managed by phase 13 (chezmoi apply)."
run mkdir -p "${HOME}/.ssh"
run chmod 700 "${HOME}/.ssh"

# ── GPG ───────────────────────────────────────────────────────────────────────
if has_command gpg; then
  info "GPG: $(gpg --version | head -1)"
  # Configure gpg-agent to use pinentry-mac (installed via Brewfile).
  _gpg_agent_conf="${HOME}/.gnupg/gpg-agent.conf"
  if ! grep -q "pinentry-program" "$_gpg_agent_conf" 2>/dev/null; then
    run mkdir -p "${HOME}/.gnupg"
    run chmod 700 "${HOME}/.gnupg"
    if ! is_dryrun; then
      echo "pinentry-program $(brew --prefix)/bin/pinentry-mac" >> "$_gpg_agent_conf"
    fi
    info "Configured gpg-agent to use pinentry-mac."
  else
    skip "gpg-agent pinentry-mac config"
  fi
  warn "To create a GPG key for git commit signing, run: gpg --gen-key"
  warn "Then: git config --global user.signingkey <KEY_ID>"
  warn "      git config --global commit.gpgsign true"
else
  warn "gpg not found — check Brewfile installation."
fi

# ── 1Password CLI ─────────────────────────────────────────────────────────────
if has_command op; then
  info "1Password CLI: $(op --version)"
else
  warn "1Password CLI not found — check Brewfile cask installation."
fi
warn "Run 'op signin' to authenticate with 1Password."

info "Security setup complete."
warn "  Add your public SSH key to GitHub: https://github.com/settings/keys"
warn "  Or run: cat ~/.ssh/id_ed25519.pub | pbcopy"
