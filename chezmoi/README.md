# Dotfiles Migration Guide

Your original dotfiles are backed up to `~/.bootstrap-backup/<timestamp>/`.

## What chezmoi manages

| Source file | Target |
|---|---|
| `dot_zshrc.tmpl` | `~/.zshrc` |
| `dot_gitconfig.tmpl` | `~/.gitconfig` |
| `dot_config/starship.toml` | `~/.config/starship.toml` |
| `dot_config/lazygit/config.yml` | `~/.config/lazygit/config.yml` |
| `dot_config/nvim/init.lua` | `~/.config/nvim/init.lua` |
| `private_dot_ssh/config.tmpl` | `~/.ssh/config` |

## Merging your old config

1. Open your backed-up `~/.zshrc`:
   ```bash
   cat ~/.bootstrap-backup/*/home__Users__*__.zshrc
   ```
2. Copy any custom aliases, exports, or function definitions into the
   **"User customizations"** section at the bottom of `dot_zshrc.tmpl`.
3. Re-apply:
   ```bash
   chezmoi apply
   ```

## Day-to-day workflow

```bash
chezmoi edit ~/.zshrc          # edit via chezmoi
chezmoi apply                  # apply changes to home dir
chezmoi diff                   # see what would change
chezmoi status                 # modified files
chezmoi add ~/.config/foo.toml # track a new file
```

## Syncing to a new machine

```bash
git clone <your-dotfiles-repo> ~/bootstrap
./bootstrap/install.sh --phase=13
```
