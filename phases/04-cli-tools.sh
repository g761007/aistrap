#!/usr/bin/env bash
# Phase 04 — Modern CLI tools shell integration
# Core tools are installed via Brewfile. This phase wires up shell integrations.

step "Modern CLI tools"

# ── fzf key bindings ──────────────────────────────────────────────────────────
_fzf_dir="$(brew --prefix)/opt/fzf"
if [[ -d "$_fzf_dir" ]]; then
  if [[ ! -f "${HOME}/.fzf.zsh" ]]; then
    info "Setting up fzf shell integration..."
    run "${_fzf_dir}/install" --all --no-bash --no-fish --no-update-rc
  else
    skip "fzf shell integration"
  fi
else
  warn "fzf not found in brew prefix — skipping key binding setup."
fi

# ── zoxide (smart cd) ─────────────────────────────────────────────────────────
if has_command zoxide; then
  append_marked "${HOME}/.zshrc" "zoxide" 'eval "$(zoxide init zsh)"'
  info "zoxide shell integration added."
else
  warn "zoxide not found — skipping."
fi

# ── delta (git diff pager) ────────────────────────────────────────────────────
if has_command delta; then
  _gitconfig="${HOME}/.gitconfig"
  if ! git config --global core.pager 2>/dev/null | grep -q delta; then
    backup_file "$_gitconfig"
    run git config --global core.pager      "delta"
    run git config --global interactive.diffFilter "delta --color-only"
    run git config --global delta.navigate  "true"
    run git config --global delta.side-by-side "true"
    run git config --global merge.conflictstyle "diff3"
    run git config --global diff.colorMoved "default"
    info "delta configured as git pager."
  else
    skip "delta git config"
  fi
else
  warn "delta not found — skipping git pager config."
fi

# ── Verify key tools ──────────────────────────────────────────────────────────
for _tool in eza bat rg fd fzf zoxide lazygit; do
  if has_command "$_tool"; then
    info "${_tool}: $(${_tool} --version 2>/dev/null | head -1 || echo 'ok')"
  else
    warn "${_tool}: NOT FOUND (brew bundle may have failed)"
  fi
done

info "CLI tools setup complete."
