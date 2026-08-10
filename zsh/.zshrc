# ~/.zshrc — portable across local (macOS) and devcontainer (Linux)

# --- Environment -------------------------------------------------------------
export AWS_PROFILE=membership
export SBT_OPTS="-Xmx4G -XX:MaxMetaspaceSize=1G"

# Personal scripts dir (only add if present)
[ -d "$HOME/scripts" ] && PATH="$PATH:$HOME/scripts"

# --- Aliases -----------------------------------------------------------------
alias push="git push origin HEAD"
alias pull="git pull origin HEAD"
alias pf="pnpm --filter"
alias p="pnpm"
alias g="git"
alias gco="git checkout"
alias gcomain="git checkout main && git pull origin main"
alias gpf="git push --force-with-lease"
alias gpullpop="git stash && git co main && git pull && git stash pop"
alias gstashpull="git stash && git pull && git stash pop"

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
