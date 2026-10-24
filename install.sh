#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

echo "==> Installing official repository packages"

sudo pacman -Syu --needed - <packages/pacman.txt

echo
echo "==> Deploying dotfiles"

stow --dotfiles --dir=stow --target="$HOME" \
  shell nvim hypr kitty fastfetch yazi waybar walker pipewire quickshell

echo
echo "==> Setup complete!"
echo "Review your desktop, shell and application settings."
echo "Install AUR packages separately from packages/aur.txt."
