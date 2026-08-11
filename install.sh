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

# --- shell -------------------------------------------------------------------
# Symlink zsh config (used on the local machine; harmless in the bash-based
# devcontainer where it simply goes unused).
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

# --- git ---------------------------------------------------------------------
# Shared, portable git config. Machine-specific bits (signing key, macOS
# credential helper, IDE merge/diff tools) live in ~/.gitconfig.local, which is
# included at the end of git/.gitconfig and is NOT part of this repo.
link "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"

echo "dotfiles install complete."
