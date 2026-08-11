#!/usr/bin/env bash
# Installs dotfiles into the current environment (devcontainer or local).
# Safe to run repeatedly (idempotent).
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  ln -sfn "$src" "$dest"
  echo "linked $dest -> $src"
}

# --- zsh ---------------------------------------------------------------------
# Ensure zsh is available (devcontainer images are Debian-based and default to bash)
if ! command -v zsh >/dev/null 2>&1; then
  echo "zsh not found; attempting to install..."
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -qq && sudo apt-get install -y -qq zsh || echo "WARN: could not install zsh"
  fi
fi

link "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"

# Shared aliases/env, sourced by both zsh and bash from a stable location
# (works whether the repo is cloned to ~/dotfiles in the container or elsewhere
# locally).
link "$DOTFILES/shell/aliases.sh" "$HOME/.aliases.sh"

# The devcontainer's default shell is bash, and tooling (e.g. devenv's mise
# setup) appends to ~/.bashrc. So DON'T symlink .bashrc — instead idempotently
# append a line that sources the shared aliases, preserving anything already
# there.
BASHRC="$HOME/.bashrc"
SOURCE_LINE='[ -f "$HOME/.aliases.sh" ] && source "$HOME/.aliases.sh"  # dotfiles'
touch "$BASHRC"
if ! grep -qF '.aliases.sh' "$BASHRC"; then
  printf '\n%s\n' "$SOURCE_LINE" >> "$BASHRC"
  echo "appended shared aliases source to $BASHRC"
else
  echo "$BASHRC already sources shared aliases"
fi

# Make zsh the default login shell for this user (best-effort; often blocked in containers)
if command -v zsh >/dev/null 2>&1; then
  ZSH_PATH="$(command -v zsh)"
  if [ "${SHELL:-}" != "$ZSH_PATH" ]; then
    sudo chsh -s "$ZSH_PATH" "$(whoami)" 2>/dev/null \
      || chsh -s "$ZSH_PATH" 2>/dev/null \
      || echo "NOTE: could not change default shell; set the terminal profile in your IDE, or 'exec zsh' from bash."
  fi
fi

# --- git ---------------------------------------------------------------------
# Shared, portable git config. Machine-specific bits (signing key, macOS
# credential helper, IDE merge/diff tools) live in ~/.gitconfig.local, which is
# included at the end of git/.gitconfig and is NOT part of this repo.
link "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"

echo "dotfiles install complete."
