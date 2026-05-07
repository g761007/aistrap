#!/usr/bin/env bash
# Machine / OS detection helpers.

detect_arch() { uname -m; }

is_apple_silicon() { [[ "$(uname -m)" == "arm64" ]]; }

brew_prefix() {
  if is_apple_silicon; then
    echo "/opt/homebrew"
  else
    echo "/usr/local"
  fi
}

# Returns the macOS major version as an integer (e.g., 13 for Ventura).
detect_macos_major() {
  sw_vers -productVersion | cut -d. -f1
}

# macos_version_check <min_major>
# Aborts if the current macOS version is below the minimum.
macos_version_check() {
  local min="$1"
  local cur
  cur=$(detect_macos_major)
  if (( cur < min )); then
    abort "macOS ${min}+ required. Current version: $(sw_vers -productVersion)"
  fi
}

# Ensure the Homebrew environment is loaded in the current shell.
ensure_brew_env() {
  local prefix
  prefix=$(brew_prefix)
  if [[ -x "${prefix}/bin/brew" ]]; then
    eval "$("${prefix}/bin/brew" shellenv)"
  fi
}
