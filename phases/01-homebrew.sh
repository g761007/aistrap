#!/usr/bin/env bash
# Phase 01 — Homebrew + Brewfile
# Installs Homebrew if missing, then runs brew bundle.

step "Homebrew"

_brew_prefix=$(brew_prefix)

if has_command brew; then
  info "Homebrew already installed at ${_brew_prefix}"
  run brew update
else
  warn "Homebrew not found. Installing..."
  if ! is_dryrun; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Load brew into the current shell session.
    eval "$("${_brew_prefix}/bin/brew" shellenv)"
  fi
  info "Homebrew installed."
fi

# Ensure brew is on PATH for subsequent steps.
ensure_brew_env

step "Brew Bundle"
info "Installing packages from Brewfile (this may take a while)..."
run brew bundle --file="${BOOTSTRAP_ROOT}/Brewfile" --no-lock

info "Homebrew setup complete."
