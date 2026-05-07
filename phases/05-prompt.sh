#!/usr/bin/env bash
# Phase 05 — Shell prompt (starship)

step "Shell prompt (starship)"

require_command starship "starship not found. Run phase 01 (homebrew) first."
has_command starship || return 0
info "starship $(starship --version | head -1)"

# ── Shell integration ─────────────────────────────────────────────────────────
append_marked "${HOME}/.zshrc" "starship" 'eval "$(starship init zsh)"'

# ── Deploy starship config ─────────────────────────────────────────────────────
_starship_cfg="${HOME}/.config/starship.toml"
_src_cfg="${BOOTSTRAP_ROOT}/chezmoi/dot_config/starship.toml"

if [[ -f "$_starship_cfg" ]]; then
  skip "starship config already exists at ${_starship_cfg}"
elif [[ -f "$_src_cfg" ]]; then
  backup_file "$_starship_cfg"
  run mkdir -p "${HOME}/.config"
  run cp "$_src_cfg" "$_starship_cfg"
  info "Deployed starship config."
fi

info "Starship prompt setup complete."
