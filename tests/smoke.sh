#!/usr/bin/env bash
# smoke.sh — Post-install smoke test.
# Verifies that the key tools from each phase are present and executable.

set -uo pipefail

if [[ -t 1 ]]; then
  _GRN='\033[0;32m'; _RED='\033[0;31m'; _YLW='\033[0;33m'
  _BLD='\033[1m'; _RST='\033[0m'
else
  _GRN=''; _RED=''; _YLW=''; _BLU=''; _BLD=''; _RST=''
fi

_PASS=0; _FAIL=0

_ok() { printf "${_GRN}  [ok]${_RST}   %s\n" "$*"; (( _PASS++ )); }
_no() { printf "${_RED}  [FAIL]${_RST} %s\n" "$*"; (( _FAIL++ )); }

_require() {
  local cmd="$1"
  if command -v "$cmd" >/dev/null 2>&1; then
    _ok "$cmd"
  else
    _no "$cmd: not found"
  fi
}

# Activate mise if available.
command -v mise >/dev/null 2>&1 && eval "$(mise activate bash)" 2>/dev/null || true

printf "${_BLD}Smoke test — checking key commands${_RST}\n\n"

printf "${_BLD}Phase 01: Homebrew${_RST}\n"
_require brew

printf "\n${_BLD}Phase 02: Shell${_RST}\n"
_require zsh
[[ -d "${HOME}/.oh-my-zsh" ]] && _ok "Oh My Zsh" || _no "Oh My Zsh not found"

printf "\n${_BLD}Phase 03: Runtime (mise)${_RST}\n"
_require mise
if command -v mise >/dev/null 2>&1; then
  for _rt in python ruby node bun; do
    _ver=$(mise current "$_rt" 2>/dev/null || echo "")
    if [[ -n "$_ver" && "$_ver" != "missing" ]]; then
      _ok "mise: ${_rt} ${_ver}"
    else
      _no "mise: ${_rt} not configured"
    fi
  done
fi

printf "\n${_BLD}Phase 04–05: CLI + Prompt${_RST}\n"
for _t in eza bat rg fd fzf zoxide lazygit delta starship; do
  _require "$_t"
done

printf "\n${_BLD}Phase 06: AI CLI tools${_RST}\n"
for _t in claude codex gemini; do
  _require "$_t"
done
[[ -x "${HOME}/.local/bin/ai-update-check" ]] && _ok "ai-update-check" || _no "ai-update-check"
[[ -x "${HOME}/.local/bin/ai-update"       ]] && _ok "ai-update"       || _no "ai-update"

printf "\n${_BLD}Phase 07–08: Python + Node${_RST}\n"
_require uv
_require pnpm
_require bun

printf "\n${_BLD}Phase 09–10: Container + Cloud${_RST}\n"
[[ -d "/Applications/OrbStack.app" ]] && _ok "OrbStack" || _no "OrbStack"
for _t in kubectl helm k9s aws gcloud terraform; do
  _require "$_t"
done

printf "\n${_BLD}Phase 11: Editors${_RST}\n"
_require nvim
[[ -d "/Applications/Visual Studio Code.app" ]] && _ok "VS Code" || _no "VS Code"

printf "\n${_BLD}Phase 12: GUI${_RST}\n"
for _app in "Raycast" "OrbStack" "Ghostty" "Warp"; do
  if [[ -d "/Applications/${_app}.app" ]]; then
    _ok "${_app}"
  else
    _no "${_app}: not installed"
  fi
done

printf "\n${_BLD}Phase 13: Dotfiles${_RST}\n"
_require chezmoi
[[ -f "${HOME}/.zshrc"     ]] && _ok "~/.zshrc"     || _no "~/.zshrc missing"
[[ -f "${HOME}/.gitconfig" ]] && _ok "~/.gitconfig" || _no "~/.gitconfig missing"

printf "\n${_BLD}Phase 14: macOS defaults${_RST}\n"
_dock=$(defaults read com.apple.dock autohide 2>/dev/null || echo "0")
[[ "$_dock" == "1" ]] && _ok "Dock: autohide" || _no "Dock autohide not set"

printf "\n${_BLD}Phase 15: Security${_RST}\n"
ls "${HOME}/.ssh/id_"* &>/dev/null 2>&1 && _ok "SSH keys present" || _no "No SSH keys found"
[[ -f "${HOME}/.ssh/config" ]] && _ok "~/.ssh/config" || _no "~/.ssh/config missing"

printf "\n${_BLD}──────────────────────────────${_RST}\n"
printf "Results: ${_GRN}PASS${_RST} ${_PASS}  ${_RED}FAIL${_RST} ${_FAIL}\n\n"

if (( _FAIL > 0 )); then
  printf "${_RED}%d check(s) failed.${_RST} Run './install.sh --doctor' for details.\n" "$_FAIL"
  exit 1
else
  printf "${_GRN}All smoke tests passed!${_RST}\n"
fi
