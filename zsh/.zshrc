# ~/.zshrc — portable across local (macOS) and devcontainer (Linux)

# --- Shared aliases + portable env (also sourced by bash) --------------------
[ -f "$HOME/.aliases.sh" ] && source "$HOME/.aliases.sh"

# --- Completions -------------------------------------------------------------
# stripe cli completions (only if the dir exists)
[ -d "$HOME/.stripe" ] && fpath=(~/.stripe $fpath)
autoload -Uz compinit && compinit -i

# --- Version managers --------------------------------------------------------
# pyenv (local machines only; guarded so it no-ops in the container)
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# mise — manages .tool-versions (e.g. guardian/devenv). Present both locally and
# in the devcontainer via the `mise` module.
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# --- Local, machine-specific overrides (not committed) -----------------------
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
