#!/usr/bin/env zsh
# ai-shell-init.zsh — Sourced from ~/.zshrc.
# Triggers the daily update check in the background and shows a notice
# if any AI CLI updates are available.

# Trigger background update check (fully detached — won't block shell startup).
if [[ -x "${HOME}/.local/bin/ai-update-check" ]]; then
  "${HOME}/.local/bin/ai-update-check" >/dev/null 2>&1 &!
fi

# Show update notice if pending file is non-empty.
_ai_pending="${HOME}/.cache/ai-tools-update/pending"
if [[ -s "$_ai_pending" ]]; then
  echo ""
  echo "  \033[1;33m⚠ AI CLI updates available:\033[0m"
  while IFS= read -r line; do
    echo "    $line"
  done < "$_ai_pending"
  echo "  Run \033[1mai-update\033[0m to upgrade."
  echo ""
fi

# Convenience alias.
alias ai-update="${HOME}/.local/bin/ai-update"
