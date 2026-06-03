#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if command -v git >/dev/null 2>&1; then
  git -C "$REPO_ROOT" pull --ff-only
else
  printf '[dotfiles-zsh] warning: git is missing; skipped pull\n' >&2
fi

exec "$REPO_ROOT/install.sh" "$@"
