#!/usr/bin/env bash
# Phase 02 — Shell setup
# Ensures zsh is the default shell and installs Oh My Zsh + plugins.

step "Shell setup"

_zsh_path="/bin/zsh"

# ── Default shell ─────────────────────────────────────────────────────────────
_current_shell=$(dscl . -read "/Users/$(whoami)" UserShell 2>/dev/null | awk '{print $2}')
if [[ "$_current_shell" == "$_zsh_path" ]]; then
  skip "Default shell is already zsh"
else
  info "Setting default shell to zsh..."
  run chsh -s "$_zsh_path"
fi

# ── Oh My Zsh ─────────────────────────────────────────────────────────────────
if [[ -d "${HOME}/.oh-my-zsh" ]]; then
  skip "Oh My Zsh already installed"
else
  info "Installing Oh My Zsh..."
  if ! is_dryrun; then
    # RUNZSH=no prevents OMZ from launching a new shell mid-script.
    # CHSH=no because we already handled chsh above.
    RUNZSH=no CHSH=no sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi
  info "Oh My Zsh installed."
fi

# ── Plugins ───────────────────────────────────────────────────────────────────
_omz_custom="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"

_clone_plugin() {
  local name="$1" url="$2"
  local dest="${_omz_custom}/plugins/${name}"
  if [[ -d "$dest" ]]; then
    skip "OMZ plugin: ${name}"
  else
    info "Cloning OMZ plugin: ${name}"
    run git clone --depth=1 "$url" "$dest"
  fi
}

_clone_plugin "zsh-autosuggestions" \
  "https://github.com/zsh-users/zsh-autosuggestions"
_clone_plugin "zsh-syntax-highlighting" \
  "https://github.com/zsh-users/zsh-syntax-highlighting"

info "Shell setup complete."
