#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "$0")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-zsh-backup-$(date +%Y%m%d%H%M%S)"

log() {
  printf '[dotfiles-zsh] %s\n' "$*"
}

backup_file() {
  local path="$1"
  if [ -e "$path" ] || [ -L "$path" ]; then
    mkdir -p "$BACKUP_DIR"
    cp -a "$path" "$BACKUP_DIR/"
    log "backed up $path -> $BACKUP_DIR"
  fi
}

install_oh_my_zsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    return 0
  fi
  log "installing oh-my-zsh"
  git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
}

install_plugin() {
  local repo="$1"
  local target="$2"
  if [ -d "$target" ]; then
    return 0
  fi
  log "installing $(basename "$target")"
  git clone --depth 1 "$repo" "$target"
}

mkdir -p "$HOME/.zsh/plugins"
install_oh_my_zsh
install_plugin https://github.com/zsh-users/zsh-autosuggestions "$HOME/.zsh/plugins/zsh-autosuggestions"
install_plugin https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.zsh/plugins/zsh-syntax-highlighting"

backup_file "$HOME/.zshrc"
ln -sfn "$REPO_ROOT/zsh/.zshrc" "$HOME/.zshrc"
log "linked ~/.zshrc"

if [ ! -f "$HOME/.zshrc.local" ]; then
  cp "$REPO_ROOT/zsh/.zshrc.local.example" "$HOME/.zshrc.local"
  log "created ~/.zshrc.local from example"
fi

if [ "${SHELL:-}" != "$(command -v zsh)" ]; then
  log "default shell is not zsh yet; run: chsh -s $(command -v zsh)"
fi

log "done. open a new terminal or run: exec zsh"
