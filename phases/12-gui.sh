#!/usr/bin/env bash
# Phase 12 — GUI productivity apps (installed via Brewfile).

step "GUI apps"

_check_app() {
  local name="$1" app_path="$2"
  if [[ -d "$app_path" ]]; then
    info "${name}: installed"
  else
    warn "${name}: not found at ${app_path}"
  fi
}

_check_app "Raycast"    "/Applications/Raycast.app"
_check_app "TablePlus"  "/Applications/TablePlus.app"
_check_app "Bruno"      "/Applications/Bruno.app"
_check_app "CleanShot"  "/Applications/CleanShot X.app"
_check_app "Rectangle"  "/Applications/Rectangle.app"
_check_app "OrbStack"   "/Applications/OrbStack.app"
_check_app "Ghostty"    "/Applications/Ghostty.app"
_check_app "Warp"       "/Applications/Warp.app"

info "GUI apps check complete."
info "  Tip: Open Raycast and set it as your Spotlight replacement (⌘Space)."
info "  Tip: Open Rectangle to enable window management."
info "  Tip: Configure CleanShot X screenshot path: ~/Pictures/Screenshots"
