# dotfiles-zsh

Portable zsh setup based on Oh My Zsh `apple` theme with:
- syntax highlighting for valid/invalid commands
- autosuggestions
- compact two-line prompt
- username, hostname, path, optional conda env, optional git branch
- right-aligned clock
- machine-local overrides via `~/.zshrc.local`

## Repo layout

- `zsh/.zshrc`: main portable config
- `zsh/.zshrc.local.example`: per-machine overrides template
- `install.sh`: bootstrap script for new machines

## First push

```bash
cd dotfiles-zsh
git init
git add .
git commit -m "Initial zsh dotfiles"
git branch -M main
git remote add origin <your-repo-url>
git push -u origin main
```

## Install on a new machine

```bash
git clone <your-repo-url> ~/dotfiles-zsh
cd ~/dotfiles-zsh
./install.sh
exec zsh
```

If the login shell is still not `zsh`, run:

```bash
chsh -s "$(command -v zsh)"
```

## Customize per machine

Edit `~/.zshrc.local` for machine-specific things like:
- proxy functions
- CUDA paths
- private aliases
- greetings
- local env setup

## Notes

- `base` conda env is hidden by default; named envs still show.
- Git info only appears inside git repositories.
- If a dependency is missing, the config skips it instead of failing.
