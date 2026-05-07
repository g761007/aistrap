#!/usr/bin/env bash
# Phase 13 — Dotfiles management (chezmoi)
# Takes over ~/.zshrc / ~/.gitconfig / ~/.ssh/config with chezmoi.
# All existing files are backed up before chezmoi applies.

step "Dotfiles (chezmoi)"

require_command chezmoi "chezmoi not found. Run phase 01 (homebrew) first."
has_command chezmoi || return 0
info "chezmoi $(chezmoi --version | head -1)"

# ── Backup current dotfiles ───────────────────────────────────────────────────
info "Backing up existing dotfiles..."
backup_file "${HOME}/.zshrc"
backup_file "${HOME}/.gitconfig"
backup_file "${HOME}/.ssh/config"
backup_dir  "${HOME}/.config"

# ── chezmoi init ──────────────────────────────────────────────────────────────
_chezmoi_src="${BOOTSTRAP_ROOT}/chezmoi"

# Check if chezmoi already points to our source directory.
_current_src=$(chezmoi source-path 2>/dev/null || echo "")

if [[ "$_current_src" == "$_chezmoi_src" ]]; then
  skip "chezmoi source already set to bootstrap chezmoi/"
elif [[ -n "$_current_src" && -d "$_current_src" ]]; then
  warn "chezmoi currently points to: ${_current_src}"
  warn "Re-initializing with bootstrap source: ${_chezmoi_src}"
  run chezmoi init --source="${_chezmoi_src}"
else
  # Source missing or not set — (re-)init with our directory.
  info "Initializing chezmoi with source: ${_chezmoi_src}"
  run chezmoi init --source="${_chezmoi_src}"
fi

# ── Show diff before applying ─────────────────────────────────────────────────
if ! is_dryrun && ! is_yes; then
  info "Showing diff (what chezmoi will change):"
  chezmoi diff || true
  pause "Review the diff above. Press Enter to apply, or Ctrl-C to abort..."
fi

# ── Apply ─────────────────────────────────────────────────────────────────────
run chezmoi apply -v

info "Dotfiles applied."
info "  Backups are at: ${BACKUP_ROOT}"
warn "  Your original ~/.zshrc content is in the backup."
warn "  Merge any custom config into: ${_chezmoi_src}/dot_zshrc.tmpl"
warn "  Then re-apply with: chezmoi apply"
