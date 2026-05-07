#!/usr/bin/env bash
# Phase 11 — Editors (VS Code + Neovim)

step "Editors"

# ── VS Code ───────────────────────────────────────────────────────────────────
if [[ -d "/Applications/Visual Studio Code.app" ]]; then
  skip "VS Code already installed"
else
  info "Installing VS Code..."
  run brew install --cask visual-studio-code
fi

# Add 'code' CLI to PATH (VS Code installs it to a non-standard location).
if has_command code; then
  info "VS Code CLI: $(code --version 2>/dev/null | head -1)"
else
  warn "VS Code 'code' CLI not found — open VS Code and run: Shell Command: Install 'code' command in PATH"
fi

# Print recommended extensions (do NOT auto-install — avoids noise and prompts).
info "Recommended VS Code extensions (install manually or via settings sync):"
cat <<'EOF'
  ms-python.python          (Python)
  charliermarsh.ruff        (Python linter)
  dbaeumer.vscode-eslint    (ESLint)
  esbenp.prettier-vscode    (Prettier)
  eamodio.gitlens           (GitLens)
  github.copilot            (GitHub Copilot)
  ms-vscode-remote.vscode-remote-extensionpack
EOF

# ── Neovim ────────────────────────────────────────────────────────────────────
if has_command nvim; then
  info "Neovim: $(nvim --version | head -1)"
else
  warn "nvim not found — check Brewfile installation."
fi

# Deploy minimal init.lua if none exists.
_nvim_cfg_dir="${HOME}/.config/nvim"
_nvim_init="${_nvim_cfg_dir}/init.lua"
_src_init="${BOOTSTRAP_ROOT}/chezmoi/dot_config/nvim/init.lua"

if [[ -f "$_nvim_init" ]]; then
  skip "Neovim config already exists at ${_nvim_init}"
elif [[ -f "$_src_init" ]]; then
  backup_dir "$_nvim_cfg_dir"
  run mkdir -p "$_nvim_cfg_dir"
  run cp "$_src_init" "$_nvim_init"
  info "Deployed minimal Neovim config."
fi

info "Editors setup complete."
