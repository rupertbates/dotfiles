# Shared aliases and portable environment.
# Sourced by BOTH zsh (~/.zshrc) and bash (~/.bashrc) so the terminal
# experience is identical regardless of which shell the container/IDE launches.
# Keep this POSIX-ish: no zsh- or bash-only syntax.

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
