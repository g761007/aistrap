#!/usr/bin/env bash
# Phase 06 — AI CLI tools (Claude Code, Codex, Gemini CLI)
# Migrates pnpm-global installs to npm -g (mise-managed Node).
# Deploys the auto-update system to ~/.local/bin/.

step "AI CLI tools"

# ── Ensure mise-managed Node is active ────────────────────────────────────────
if has_command mise; then
  eval "$(mise activate bash)" 2>/dev/null || true
fi

require_command node "Node.js not found. Run phase 03 (runtime) first."
has_command node || { is_dryrun && log "  [dry-run] skipping npm operations (node not installed)"; return 0; }
info "Node: $(node --version)  npm: $(npm --version)"

# ── Migrate pnpm-global AI CLIs to npm -g ────────────────────────────────────
# Codex and Gemini may be installed under ~/Library/pnpm from a previous setup.
_pnpm_globals="${HOME}/Library/pnpm"
for _pkg_name in "@openai/codex" "@google/gemini-cli"; do
  _bin="${_pnpm_globals}/$(basename "${_pkg_name##*/}")"   # rough check
  if [[ -d "$_pnpm_globals" ]] && has_command pnpm; then
    _installed=$(pnpm ls -g --depth=0 2>/dev/null | grep "${_pkg_name}" || true)
    if [[ -n "$_installed" ]]; then
      warn "Migrating ${_pkg_name} from pnpm → npm -g"
      run pnpm remove -g "${_pkg_name}" 2>/dev/null || true
    fi
  fi
done

# ── Install / upgrade AI CLIs via npm -g ─────────────────────────────────────
_ai_pkgs=("@anthropic-ai/claude-code" "@openai/codex" "@google/gemini-cli")

for _pkg in "${_ai_pkgs[@]}"; do
  if npm ls -g "${_pkg}" --depth=0 &>/dev/null; then
    info "${_pkg}: already installed — upgrading"
    run npm update -g "${_pkg}"
  else
    info "Installing ${_pkg}..."
    run npm install -g "${_pkg}"
  fi
done

# ── Deploy auto-update helper scripts ────────────────────────────────────────
_local_bin="${HOME}/.local/bin"
ensure_dir "$_local_bin"

for _script in ai-update-check ai-update ai-shell-init.zsh; do
  _src="${BOOTSTRAP_ROOT}/ai-tools/${_script}"
  _dst="${_local_bin}/${_script}"
  if [[ -f "$_src" ]]; then
    run cp "$_src" "$_dst"
    run chmod +x "$_dst"
    info "Deployed ${_script} → ${_dst}"
  else
    warn "Source not found: ${_src} (run will deploy once ai-tools/ is written)"
  fi
done

# ── Shell integration ─────────────────────────────────────────────────────────
append_marked "${HOME}/.zshrc" "ai-update" \
  '[[ -f "${HOME}/.local/bin/ai-shell-init.zsh" ]] && source "${HOME}/.local/bin/ai-shell-init.zsh"'

# Ensure ~/.local/bin is on PATH.
append_marked "${HOME}/.zshrc" "local-bin-path" \
  'export PATH="${HOME}/.local/bin:${PATH}"'

# ── Verify ────────────────────────────────────────────────────────────────────
for _cmd in claude codex gemini; do
  if has_command "$_cmd"; then
    info "${_cmd}: $(${_cmd} --version 2>/dev/null | head -1 || echo 'ok')"
  else
    warn "${_cmd}: not found after install — check npm prefix"
  fi
done

info "AI CLI tools setup complete."
