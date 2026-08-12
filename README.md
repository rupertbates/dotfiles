# dotfiles

Personal dotfiles for use both on my local macOS machine and inside
[guardian/devenv](https://github.com/guardian/devenv) devcontainers, so the
shell (and git) experience is identical in both.

## Overview

| Path                     | Purpose                                                            |
|--------------------------|--------------------------------------------------------------------|
| `install.sh`             | Symlinks configs into `$HOME`; wires shared aliases into bash       |
| `zsh/.zshrc`             | Portable zsh config (Mac-only bits are guarded so they no-op)      |
| `shell/aliases.sh`       | Aliases + portable env, sourced by both zsh and bash              |
| `git/.gitconfig`         | Portable git config; machine bits go in `~/.gitconfig.local`       |
| `ssh/github_known_hosts` | GitHub's verified host keys, merged into `~/.ssh/known_hosts`       |
| `examples/devenv.yaml` | Reference copy of my host-side devenv user config (backup/template) |

The devcontainer's default shell is **bash** (both `devsh.sh` and the IntelliJ
terminal launch bash), so aliases live in `shell/aliases.sh` and are sourced by
both shells: directly from `~/.zshrc`, and via a line `install.sh` appends to
`~/.bashrc`. This keeps the alias/env experience identical in the container
(bash) and locally (zsh).

Anything machine-specific (GPG signing key, macOS keychain credential helper,
IntelliJ/VS Code merge & diff tool paths, extra secrets) is **not** committed.
It lives in per-machine files that the committed configs opt into:

- `~/.gitconfig.local` — included by `git/.gitconfig`
- `~/.zshrc.local` — sourced by `zsh/.zshrc`

## How devenv uses this

Reference this repo from your **user** config at
`~/.config/devenv/devenv.yaml` (not the checked-in project file):

```yaml
dotfiles:
  repository: "https://github.com/rupertbates/dotfiles"
  targetPath: "~/dotfiles"
  installCommand: "./install.sh"
plugins:
  vscode:
    - eamodio.gitlens
  intellij:
    - IdeaVIM
```

devenv clones this repo into the container at `targetPath` and runs
`installCommand` after the project/container setup completes.

A reference copy of my full user config lives at
[`examples/devenv.yaml`](examples/devenv.yaml). devenv does **not** read it from
there — it reads `~/.config/devenv/devenv.yaml` on the host before any container
exists — so the copy is only a backup/template. On a new machine, restore it
with:

```bash
mkdir -p ~/.config/devenv
cp examples/devenv.yaml ~/.config/devenv/devenv.yaml
```

IDE **settings/keymaps/themes** are not handled here — use VS Code
**Settings Sync** and JetBrains **Settings Sync** instead. IDE **plugins** are
listed under `plugins:` in the devenv user config above.

## How to test

Locally, run against a scratch HOME so it can't touch your real config:

```bash
HOME="$(mktemp -d)" bash install.sh
ls -la "$HOME"        # verify .zshrc and .gitconfig symlinks
```

Lint the script:

```bash
shellcheck install.sh   # if shellcheck is installed
bash -n install.sh      # syntax check
```

In a devcontainer, open a fresh terminal after container creation and confirm
the shared aliases and git config are loaded (the shell there is bash):

```bash
type g                  # should show: g is aliased to `git'
echo "$AWS_PROFILE"      # from shell/aliases.sh
git config --list       # aliases/user present
```

## References

- devenv: https://github.com/guardian/devenv
- devenv configuration reference: https://github.com/guardian/devenv/blob/main/docs/configuration.md
- Containerised development docs: https://github.com/guardian/devenv/blob/main/docs/containerised-development/containerised-development.md
- mise: https://mise.jdx.dev/
