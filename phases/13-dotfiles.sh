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

# ── chezmoi config ───────────────────────────────────────────────────────────
# Write chezmoi.toml pointing directly to our source directory.
# This avoids relying on `chezmoi init` creating ~/.local/share/chezmoi.
_chezmoi_src="${BOOTSTRAP_ROOT}/chezmoi"
_chezmoi_cfg_dir="${HOME}/.config/chezmoi"

if ! is_dryrun; then
  mkdir -p "$_chezmoi_cfg_dir"
  # Preserve existing chezmoi.toml if it already points to our source.
  _existing_src=$(chezmoi source-path 2>/dev/null || echo "")
  if [[ "$_existing_src" != "$_chezmoi_src" ]]; then
    backup_file "${_chezmoi_cfg_dir}/chezmoi.toml"
    printf 'sourceDir = "%s"\n' "${_chezmoi_src}" > "${_chezmoi_cfg_dir}/chezmoi.toml"
    info "Wrote chezmoi config: sourceDir = ${_chezmoi_src}"
  else
    skip "chezmoi config already points to bootstrap chezmoi/"
  fi
else
  printf "${_YLW}  [dry-run]${_RST} write chezmoi.toml sourceDir = %s\n" "$_chezmoi_src" >&2
fi

# ── Show diff before applying ─────────────────────────────────────────────────
if ! is_dryrun && ! is_yes; then
  info "Showing diff (what chezmoi will change):"
  chezmoi diff --source="${_chezmoi_src}" || true
  pause "Review the diff above. Press Enter to apply, or Ctrl-C to abort..."
fi

# ── Apply ─────────────────────────────────────────────────────────────────────
run chezmoi apply --source="${_chezmoi_src}" -v

info "Dotfiles applied."
info "  Backups are at: ${BACKUP_ROOT}"
warn "  Your original ~/.zshrc content is in the backup."
warn "  Merge any custom config into: ${_chezmoi_src}/dot_zshrc.tmpl"
warn "  Then re-apply with: chezmoi apply"
