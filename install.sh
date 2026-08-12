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

# --- ssh ---------------------------------------------------------------------
# Pre-seed GitHub's host keys so `git push`/`git pull` over SSH don't prompt
# "The authenticity of host 'github.com' can't be established" on a fresh
# container. These keys are GitHub's official published keys (fingerprints
# verified, NOT trust-on-first-use). Merged idempotently into known_hosts.
mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
KNOWN_HOSTS="$HOME/.ssh/known_hosts"
touch "$KNOWN_HOSTS" && chmod 644 "$KNOWN_HOSTS"
while IFS= read -r key_line; do
  [ -z "$key_line" ] && continue
  if ! grep -qF "$key_line" "$KNOWN_HOSTS"; then
    printf '%s\n' "$key_line" >> "$KNOWN_HOSTS"
    echo "added GitHub host key to $KNOWN_HOSTS"
  fi
done < "$DOTFILES/ssh/github_known_hosts"

# --- git ---------------------------------------------------------------------
# Shared, portable git config. Machine-specific bits (signing key, macOS
# credential helper, IDE merge/diff tools) live in ~/.gitconfig.local, which is
# included at the end of git/.gitconfig and is NOT part of this repo.
link "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"

echo "dotfiles install complete."
