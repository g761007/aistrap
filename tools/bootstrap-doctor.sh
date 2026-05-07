#!/usr/bin/env bash
# bootstrap-doctor — Health check for the workstation setup.
# Can be run standalone: bash tools/bootstrap-doctor.sh

set -uo pipefail

# ── Color setup ───────────────────────────────────────────────────────────────
if [[ -t 1 ]] && [[ -z "${NO_COLOR:-}" ]]; then
  _GRN='\033[0;32m'; _RED='\033[0;31m'; _YLW='\033[0;33m'
  _BLU='\033[0;34m'; _BLD='\033[1m';    _RST='\033[0m'
else
  _GRN=''; _RED=''; _YLW=''; _BLU=''; _BLD=''; _RST=''
fi

_PASS=0; _WARN=0; _FAIL=0

_pass() { printf "${_GRN}  [PASS]${_RST} %s\n" "$*"; (( _PASS++ )); }
_warn() { printf "${_YLW}  [WARN]${_RST} %s\n" "$*"; (( _WARN++ )); }
_fail() { printf "${_RED}  [FAIL]${_RST} %s\n" "$*"; (( _FAIL++ )); }

_check_cmd() {
  local name="$1" cmd="${2:-$1}" label="${3:-}"
  if command -v "$cmd" >/dev/null 2>&1; then
    local ver
    ver=$(${cmd} --version 2>/dev/null | head -1 || echo "ok")
    _pass "${name}: ${ver}${label:+ — ${label}}"
  else
    _fail "${name}: not found"
  fi
}

_check_app() {
  local name="$1" path="$2"
  if [[ -d "$path" ]]; then
    _pass "${name}: installed"
  else
    _warn "${name}: not found at ${path}"
  fi
}

printf "\n${_BLD}${_BLU}╔══════════════════════════════════╗${_RST}\n"
printf   "${_BLD}${_BLU}║   Bootstrap Doctor               ║${_RST}\n"
printf   "${_BLD}${_BLU}╚══════════════════════════════════╝${_RST}\n\n"

# ── System ────────────────────────────────────────────────────────────────────
printf "${_BLD}System${_RST}\n"
_pass "macOS: $(sw_vers -productVersion) ($(uname -m))"
_check_cmd "Xcode CLT" xcode-select "$(xcode-select -p 2>/dev/null)"

# ── Package manager ───────────────────────────────────────────────────────────
printf "\n${_BLD}Package Manager${_RST}\n"
_check_cmd "brew" brew

# ── Shell ─────────────────────────────────────────────────────────────────────
printf "\n${_BLD}Shell${_RST}\n"
_check_cmd "zsh"      zsh
_check_cmd "starship" starship

if [[ -d "${HOME}/.oh-my-zsh" ]]; then
  _pass "Oh My Zsh: installed"
else
  _warn "Oh My Zsh: not found"
fi

# ── Runtime management ────────────────────────────────────────────────────────
printf "\n${_BLD}Runtime Management (mise)${_RST}\n"
_check_cmd "mise" mise

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)" 2>/dev/null || true
  for _rt in python ruby node bun; do
    _ver=$(mise current "$_rt" 2>/dev/null || echo "")
    if [[ -n "$_ver" && "$_ver" != "missing" ]]; then
      _pass "${_rt}: ${_ver}"
    else
      _fail "${_rt}: not configured in mise"
    fi
  done
fi

# ── Modern CLI tools ─────────────────────────────────────────────────────────
printf "\n${_BLD}Modern CLI Tools${_RST}\n"
for _tool in eza bat rg fd fzf zoxide lazygit delta; do
  _check_cmd "$_tool"
done

# ── AI CLI tools ─────────────────────────────────────────────────────────────
printf "\n${_BLD}AI CLI Tools${_RST}\n"
for _ai in claude codex gemini; do
  _check_cmd "$_ai"
done

if [[ -f "${HOME}/.local/bin/ai-update-check" ]]; then
  _pass "ai-update-check: installed"
else
  _warn "ai-update-check: not found at ~/.local/bin/ai-update-check"
fi
if [[ -f "${HOME}/.local/bin/ai-update" ]]; then
  _pass "ai-update: installed"
else
  _warn "ai-update: not found at ~/.local/bin/ai-update"
fi

# ── Python ────────────────────────────────────────────────────────────────────
printf "\n${_BLD}Python Tooling${_RST}\n"
_check_cmd "uv" uv
command -v python3 >/dev/null 2>&1 && _pass "python3: $(python3 --version 2>&1)"

# ── Node.js ecosystem ─────────────────────────────────────────────────────────
printf "\n${_BLD}Node.js Ecosystem${_RST}\n"
_check_cmd "node" node
_check_cmd "npm"  npm
_check_cmd "pnpm" pnpm
_check_cmd "bun"  bun

# ── Container / Kubernetes ────────────────────────────────────────────────────
printf "\n${_BLD}Container & Kubernetes${_RST}\n"
_check_app "OrbStack" "/Applications/OrbStack.app"
_check_cmd "kubectl"
_check_cmd "helm"
_check_cmd "k9s"

# ── Cloud CLI ─────────────────────────────────────────────────────────────────
printf "\n${_BLD}Cloud CLI${_RST}\n"
_check_cmd "aws"        aws
_check_cmd "gcloud"     gcloud
_check_cmd "terraform"  terraform

if command -v gcloud >/dev/null 2>&1; then
  _project=$(gcloud config get-value project 2>/dev/null || echo "")
  if [[ -n "$_project" ]]; then
    _pass "gcloud project: ${_project}"
  else
    _warn "gcloud: not initialized (run 'gcloud init')"
  fi
fi

# ── Editors ───────────────────────────────────────────────────────────────────
printf "\n${_BLD}Editors${_RST}\n"
_check_app "VS Code"  "/Applications/Visual Studio Code.app"
_check_cmd "nvim"
_check_cmd "chezmoi"

# ── Security ─────────────────────────────────────────────────────────────────
printf "\n${_BLD}Security${_RST}\n"
if ls "${HOME}/.ssh/id_"* &>/dev/null 2>&1; then
  _pass "SSH keys: found"
else
  _warn "SSH keys: none found in ~/.ssh/"
fi

if [[ -f "${HOME}/.ssh/config" ]]; then
  _pass "~/.ssh/config: exists"
else
  _warn "~/.ssh/config: missing"
fi

if command -v gpg >/dev/null 2>&1; then
  _gpg_keys=$(gpg --list-secret-keys 2>/dev/null | grep -c "^sec" || true)
  if (( _gpg_keys > 0 )); then
    _pass "GPG keys: ${_gpg_keys} secret key(s)"
  else
    _warn "GPG keys: none (run 'gpg --gen-key' to create one)"
  fi
fi

# ── git config ────────────────────────────────────────────────────────────────
printf "\n${_BLD}Git Config${_RST}\n"
_git_name=$(git config --global user.name 2>/dev/null || echo "")
_git_email=$(git config --global user.email 2>/dev/null || echo "")

if [[ -n "$_git_name" ]];  then _pass "git user.name: ${_git_name}";  else _fail "git user.name: not set"; fi
if [[ -n "$_git_email" ]]; then _pass "git user.email: ${_git_email}"; else _fail "git user.email: not set"; fi

_git_pager=$(git config --global core.pager 2>/dev/null || echo "")
if echo "$_git_pager" | grep -q delta; then
  _pass "git pager: delta"
else
  _warn "git pager: not set to delta"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
printf "\n${_BLD}────────────────────────────────────${_RST}\n"
printf "${_GRN}PASS${_RST}: ${_PASS}  ${_YLW}WARN${_RST}: ${_WARN}  ${_RED}FAIL${_RST}: ${_FAIL}\n"

if (( _FAIL > 0 )); then
  printf "\n${_RED}Some checks failed.${_RST} Re-run the relevant phase:\n"
  printf "  ./install.sh --phase=01   # Homebrew / packages\n"
  printf "  ./install.sh --phase=04   # Modern CLI tools\n"
  printf "  ./install.sh --phase=06   # AI CLI tools\n"
  printf "\n"
  exit 1
elif (( _WARN > 0 )); then
  printf "\n${_YLW}Setup is functional with some warnings.${_RST}\n"
else
  printf "\n${_GRN}All checks passed. Your workstation is ready!${_RST}\n"
fi
