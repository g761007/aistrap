#!/usr/bin/env bash
# Phase 14 — macOS system defaults
# Backs up current values before writing. Run 'killall Finder Dock' at end.

step "macOS defaults"

# Helper: saves old value to backup JSON before writing new one.
_defaults_write() {
  local domain="$1" key="$2" type="$3" value="$4"

  if ! is_dryrun; then
    # Read current value for the backup record.
    local cur
    cur=$(defaults read "$domain" "$key" 2>/dev/null || echo "<not set>")
    printf '{"domain":"%s","key":"%s","was":"%s"}\n' \
      "$domain" "$key" "$cur" >> "${BACKUP_ROOT}/macos-defaults.jsonl"
  fi

  run defaults write "$domain" "$key" "$type" "$value"
}

mkdir -p "${BACKUP_ROOT}"

# ── Finder ────────────────────────────────────────────────────────────────────
info "Finder: show hidden files, path bar, full path in title"
_defaults_write com.apple.finder AppleShowAllFiles        -bool  true
_defaults_write com.apple.finder ShowPathbar              -bool  true
_defaults_write com.apple.finder _FXShowPosixPathInTitle  -bool  true
_defaults_write com.apple.finder FXPreferredViewStyle     -string "Nlsv"  # list view
_defaults_write com.apple.finder FXDefaultSearchScope     -string "SCcf"  # current folder

# ── Dock ─────────────────────────────────────────────────────────────────────
info "Dock: auto-hide, no animation, minimize to icon"
_defaults_write com.apple.dock autohide                -bool  true
_defaults_write com.apple.dock autohide-delay          -float 0
_defaults_write com.apple.dock autohide-time-modifier  -float 0.3
_defaults_write com.apple.dock minimize-to-application -bool  true
_defaults_write com.apple.dock show-recents            -bool  false

# ── Keyboard ─────────────────────────────────────────────────────────────────
info "Keyboard: fast key repeat, disable press-and-hold"
_defaults_write -g KeyRepeat         -int  2
_defaults_write -g InitialKeyRepeat  -int  15
_defaults_write -g ApplePressAndHoldEnabled -bool false

# ── Screenshot ───────────────────────────────────────────────────────────────
info "Screenshot: custom save path ~/Pictures/Screenshots"
_screenshots_dir="${HOME}/Pictures/Screenshots"
if ! is_dryrun; then
  mkdir -p "$_screenshots_dir"
fi
_defaults_write com.apple.screencapture location -string "$_screenshots_dir"
_defaults_write com.apple.screencapture type     -string "png"
_defaults_write com.apple.screencapture disable-shadow -bool true

# ── Trackpad / Mouse ─────────────────────────────────────────────────────────
info "Trackpad: tap-to-click"
_defaults_write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
_defaults_write -g com.apple.mouse.tapBehavior -int 1

# ── Restart affected apps ─────────────────────────────────────────────────────
if ! is_dryrun; then
  info "Restarting Finder and Dock to apply changes..."
  killall Finder 2>/dev/null || true
  killall Dock   2>/dev/null || true
fi

info "macOS defaults applied."
info "  Backup of previous values: ${BACKUP_ROOT}/macos-defaults.jsonl"
