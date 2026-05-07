#!/usr/bin/env bash
# bootstrap-uninstall — Removes bootstrap marker blocks from shell config files.
# Does NOT uninstall brew packages or delete any files.

set -euo pipefail

BOOTSTRAP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for _lib in common machine backup append; do
  source "${BOOTSTRAP_ROOT}/lib/${_lib}.sh"
done

step "Bootstrap uninstall"
warn "This removes bootstrap marker blocks from ~/.zshrc."
warn "It does NOT uninstall any packages or delete files."
printf "\nContinue? [y/N] "
read -r _ans
[[ "${_ans,,}" == "y" || "${_ans,,}" == "yes" ]] || { log "Aborted."; exit 0; }

_markers=(
  "mise"
  "starship"
  "zoxide"
  "ai-update"
  "local-bin-path"
  "kubectl"
  "gcloud"
  "uv"
  "uv-aliases"
  "pnpm"
)

for _marker in "${_markers[@]}"; do
  if grep -qF "# >>> bootstrap:${_marker} >>>" "${HOME}/.zshrc" 2>/dev/null; then
    backup_file "${HOME}/.zshrc"
    remove_marked "${HOME}/.zshrc" "$_marker"
    info "Removed marker block: ${_marker}"
  fi
done

info "Uninstall complete."
log "Your ~/.zshrc has been cleaned. Backup at: ${BACKUP_ROOT}"
log "To fully remove, also run: rm -rf ~/.oh-my-zsh ~/.local/bin/ai-*"
