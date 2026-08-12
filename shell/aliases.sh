# Shared aliases and portable environment.
# Sourced by BOTH zsh (~/.zshrc) and bash (~/.bashrc) so the terminal
# experience is identical regardless of which shell the container/IDE launches.
# Keep this POSIX-ish: no zsh- or bash-only syntax.

# --- Environment -------------------------------------------------------------
export AWS_PROFILE=membership
export SBT_OPTS="-Xmx4G -XX:MaxMetaspaceSize=1G"

# Personal scripts dir (only add if present)
[ -d "$HOME/scripts" ] && PATH="$PATH:$HOME/scripts"

# --- SSH agent discovery (devcontainer) --------------------------------------
# In a devcontainer the IDE forwards the host ssh-agent as a socket in /tmp, but
# only IDE-spawned processes get SSH_AUTH_SOCK set. A plain shell (e.g. devsh /
# docker exec) starts with no SSH_AUTH_SOCK, so git push fails with
# "Permission denied (publickey)". If our agent isn't reachable/loaded, scan
# /tmp for a forwarded socket that actually holds a key and use it.
# `ssh-add -l` exits 0 only when an agent is reachable AND has identities, so a
# working setup skips the scan entirely.
if command -v ssh-add >/dev/null 2>&1 && ! ssh-add -l >/dev/null 2>&1; then
  for _sock in $(ls -1t /tmp 2>/dev/null); do
    _cand="/tmp/$_sock"
    [ -S "$_cand" ] || continue
    if SSH_AUTH_SOCK="$_cand" ssh-add -l >/dev/null 2>&1; then
      export SSH_AUTH_SOCK="$_cand"
      break
    fi
  done
  unset _sock _cand
fi

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
