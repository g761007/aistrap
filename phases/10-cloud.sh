#!/usr/bin/env bash
# Phase 10 — Cloud CLI tools
# awscli / google-cloud-sdk / terraform (installed via Brewfile).

step "Cloud CLI tools"

# ── AWS CLI ───────────────────────────────────────────────────────────────────
if has_command aws; then
  info "AWS CLI: $(aws --version 2>&1 | head -1)"
else
  warn "aws CLI not found — check Brewfile installation."
fi

# ── gcloud ────────────────────────────────────────────────────────────────────
if has_command gcloud; then
  info "gcloud: $(gcloud --version 2>/dev/null | head -1)"

  # gcloud installs to a cask path; ensure it's on PATH via shell config.
  _gcloud_path="$(brew --prefix)/share/google-cloud-sdk"
  if [[ -f "${_gcloud_path}/path.zsh.inc" ]]; then
    append_marked "${HOME}/.zshrc" "gcloud" \
      "source '${_gcloud_path}/path.zsh.inc'
source '${_gcloud_path}/completion.zsh.inc'"
  fi
else
  warn "gcloud not found — check Brewfile cask installation."
fi

# ── Terraform ────────────────────────────────────────────────────────────────
if has_command terraform; then
  info "Terraform: $(terraform version 2>/dev/null | head -1)"
else
  warn "terraform not found — check Brewfile installation."
fi

info "Cloud CLI setup complete."
warn "  Run 'aws configure' to set up AWS credentials."
warn "  Run 'gcloud init' to authenticate with Google Cloud."
