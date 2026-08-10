# dotfiles

Personal dotfiles for use both on my local macOS machine and inside
[guardian/devenv](https://github.com/guardian/devenv) devcontainers, so the
shell (and git) experience is identical in both.

## Overview

| Path            | Purpose                                                            |
|-----------------|-------------------------------------------------------------------|
| `install.sh`    | Symlinks configs into `$HOME`; installs zsh in the container       |
| `zsh/.zshrc`    | Portable zsh config (Mac-only bits are guarded so they no-op)      |
| `git/.gitconfig`| Portable git config; machine bits go in `~/.gitconfig.local`       |

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

In a devcontainer, open a fresh terminal after container creation and confirm:

```bash
echo "$SHELL"           # should point at zsh (or run 'exec zsh')
git config --list       # aliases/user present
```

## References

- devenv: https://github.com/guardian/devenv
- devenv configuration reference: https://github.com/guardian/devenv/blob/main/docs/configuration.md
- Containerised development docs: https://github.com/guardian/devenv/blob/main/docs/containerised-development/containerised-development.md
- mise: https://mise.jdx.dev/
