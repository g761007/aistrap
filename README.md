# Mac AI Developer Workstation Bootstrap

One-command setup for a modern, AI-native macOS development environment.

## Quick start

```bash
# Step 1: Install Xcode Command Line Tools (required on a fresh Mac)
xcode-select --install

# Step 2: Clone this repo
git clone <repo-url> ~/bootstrap
cd ~/bootstrap

# Step 3: Run bootstrap
./install.sh
```

> Future: `curl -fsSL https://<your-host>/install.sh | bash` — URL TBD.

## What gets installed

| Phase | Description |
|-------|-------------|
| 00 | Preflight checks (macOS version, Xcode CLT, disk space) |
| 01 | Homebrew + Brewfile (all CLI tools and GUI apps) |
| 02 | zsh + Oh My Zsh + plugins |
| 03 | Runtime management: mise → Python / Ruby / Node / Bun |
| 04 | Modern CLI: eza / bat / ripgrep / fd / fzf / zoxide / lazygit / delta |
| 05 | Starship prompt |
| 06 | AI CLI: Claude Code / Codex / Gemini + auto-update system |
| 07 | Python tooling: uv (pip/venv/poetry replacement) |
| 08 | Node ecosystem: pnpm / bun |
| 09 | Container & Kubernetes: OrbStack / kubectl / helm / k9s |
| 10 | Cloud CLI: awscli / gcloud / terraform |
| 11 | Editors: VS Code + Neovim |
| 12 | GUI apps: Raycast / TablePlus / Bruno / CleanShot / Rectangle |
| 13 | Dotfiles: chezmoi takes over ~/.zshrc / ~/.gitconfig / ~/.ssh/config |
| 14 | macOS defaults: Finder / Dock / Keyboard / Screenshot |
| 15 | Security: SSH key / GPG / 1Password CLI |
| 99 | Doctor: health check |

## Usage

```bash
./install.sh                       # Interactive — confirms each phase
./install.sh --yes                 # Non-interactive — run everything
./install.sh --dry-run --yes       # Preview all actions without executing
./install.sh --phase=04            # Run only phase 04
./install.sh --phase=01..06        # Run phases 01 through 06
./install.sh --skip=09,12          # Skip container and GUI phases
./install.sh --doctor              # Health check only
```

## Design principles

- **Idempotent**: safe to re-run — already-installed items are skipped
- **Backup-first**: every file write is preceded by a backup to `~/.bootstrap-backup/<timestamp>/`
- **Modular**: each phase is an independent script in `phases/`
- **Dry-run support**: `--dry-run` previews all actions without executing
- **Apple Silicon + Intel**: auto-detects architecture for Homebrew prefix

## AI CLI auto-update

The bootstrap installs a background update checker for Claude Code, Codex, and Gemini CLI:

- Runs in the background when you open a new shell (non-blocking)
- Checks at most once per day
- Prints a notice if updates are available
- Run `ai-update` to upgrade all three at once

## Dotfiles

Dotfiles are managed by [chezmoi](https://chezmoi.io) with source in `chezmoi/`.

```bash
chezmoi edit ~/.zshrc    # edit via chezmoi
chezmoi apply            # apply to home directory
chezmoi diff             # preview changes
```

See `chezmoi/README.md` for the migration guide from your existing dotfiles.

## Health check

```bash
./install.sh --doctor
# or
bash tools/bootstrap-doctor.sh
```

## Cleanup

```bash
# Remove bootstrap marker blocks from ~/.zshrc (does not uninstall packages)
bash tools/bootstrap-uninstall.sh

# Run smoke tests
bash tests/smoke.sh
```

## Stack

```
Ghostty / Warp
+ zsh + starship + Oh My Zsh
+ mise (python / ruby / node / bun)
+ uv + pnpm
+ eza + bat + fd + ripgrep + zoxide + fzf
+ lazygit + delta
+ tmux + neovim
+ claude-code + codex + gemini-cli
+ gh + kubectl + k9s
+ OrbStack + Raycast
+ chezmoi
```
