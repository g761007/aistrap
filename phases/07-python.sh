#!/usr/bin/env bash
# Phase 07 — Python tooling (uv)
# uv replaces pip / venv / poetry.

step "Python tooling (uv)"

require_command uv "uv not found. Run phase 01 (homebrew) first."
has_command uv || return 0
info "uv $(uv --version)"

# ── Shell integration ─────────────────────────────────────────────────────────
# uv generates completions; add them to the shell.
append_marked "${HOME}/.zshrc" "uv" \
'# uv completions
if has_command uv; then
  eval "$(uv generate-shell-completion zsh 2>/dev/null)"
fi'

# ── Helpful aliases ───────────────────────────────────────────────────────────
# These live in chezmoi/dot_zshrc.tmpl for the managed-dotfile path.
# In the append path (non-chezmoi managed), add them here.
append_marked "${HOME}/.zshrc" "uv-aliases" \
'alias pip="uv pip"
alias venv="uv venv"'

info "Python (uv) setup complete."
info "  Use 'uv pip install <pkg>' instead of pip"
info "  Use 'uv venv' to create virtual environments"
info "  Use 'uvx <tool>' to run one-off tools without installing"
