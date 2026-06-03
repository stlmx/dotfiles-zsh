#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${DOTFILES_BACKUP_DIR:-$HOME/.dotfiles-zsh-backup-$(date +%Y%m%d%H%M%S)}"
SKIP_INSTALLS="${DOTFILES_SKIP_INSTALLS:-0}"

log() {
  printf '[dotfiles-zsh] %s\n' "$*"
}

warn() {
  printf '[dotfiles-zsh] warning: %s\n' "$*" >&2
}

have() {
  command -v "$1" >/dev/null 2>&1
}

backup_path() {
  local path="$1"
  if [ ! -e "$path" ] && [ ! -L "$path" ]; then
    return 0
  fi

  mkdir -p "$BACKUP_DIR"
  cp -a "$path" "$BACKUP_DIR/$(basename "$path")"
  log "backed up $path -> $BACKUP_DIR"
}

link_file() {
  local src="$1"
  local dest="$2"
  local dest_dir
  dest_dir="$(dirname "$dest")"
  mkdir -p "$dest_dir"

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    log "already linked $dest"
    return 0
  fi

  backup_path "$dest"
  ln -sfn "$src" "$dest"
  log "linked $dest -> $src"
}

install_starship() {
  if have starship; then
    return 0
  fi

  if [ "$SKIP_INSTALLS" = "1" ]; then
    warn "starship is missing; skipped install because DOTFILES_SKIP_INSTALLS=1"
    return 0
  fi

  log "installing starship"
  mkdir -p "$HOME/.local/bin"

  if have brew; then
    if ! brew install starship; then
      warn "brew failed to install starship"
    fi
    return 0
  fi

  if have curl; then
    if ! curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"; then
      warn "curl installer failed to install starship"
    fi
    return 0
  fi

  warn "starship is missing and curl is unavailable; install starship manually"
}

install_oh_my_zsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    return 0
  fi

  if [ "$SKIP_INSTALLS" = "1" ]; then
    warn "oh-my-zsh is missing; skipped install because DOTFILES_SKIP_INSTALLS=1"
    return 0
  fi

  if ! have git; then
    warn "git is missing; cannot install oh-my-zsh"
    return 0
  fi

  log "installing oh-my-zsh"
  if ! git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"; then
    warn "failed to install oh-my-zsh"
  fi
}

install_plugin() {
  local repo="$1"
  local target="$2"

  if [ -d "$target" ]; then
    return 0
  fi

  if [ "$SKIP_INSTALLS" = "1" ]; then
    warn "$(basename "$target") is missing; skipped install because DOTFILES_SKIP_INSTALLS=1"
    return 0
  fi

  if ! have git; then
    warn "git is missing; cannot install $(basename "$target")"
    return 0
  fi

  log "installing $(basename "$target")"
  if ! git clone --depth 1 "$repo" "$target"; then
    warn "failed to install $(basename "$target")"
  fi
}

if ! have zsh; then
  warn "zsh is missing; install it with your system package manager before switching shells"
fi

install_starship
install_oh_my_zsh
mkdir -p "$HOME/.zsh/plugins"
install_plugin https://github.com/zsh-users/zsh-autosuggestions "$HOME/.zsh/plugins/zsh-autosuggestions"
install_plugin https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.zsh/plugins/zsh-syntax-highlighting"

link_file "$REPO_ROOT/zsh/.zshrc" "$HOME/.zshrc"
link_file "$REPO_ROOT/starship/starship.toml" "$HOME/.config/starship.toml"

if [ ! -f "$HOME/.zshrc.local" ]; then
  cp "$REPO_ROOT/zsh/.zshrc.local.example" "$HOME/.zshrc.local"
  log "created ~/.zshrc.local from example"
else
  log "kept existing ~/.zshrc.local"
fi

if have zsh; then
  zsh_path="$(command -v zsh)"
  if [ "${SHELL:-}" != "$zsh_path" ]; then
    log "default shell is not zsh yet; run: chsh -s $zsh_path"
  fi
fi

log "done. open a new terminal or run: exec zsh"
