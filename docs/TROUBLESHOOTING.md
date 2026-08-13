# Troubleshooting Guide

Common issues and solutions when using the ubuntu-setup installation script.

## Installation Script Issues

### Permission denied

**Problem:** `bash: ./install.sh: Permission denied`

**Solution:**

```bash
chmod +x install.sh uninstall.sh library_scripts/*.sh scripts/ci-smoke.sh
./install.sh
```

### Command not found

**Problem:** `./install.sh: command not found`

**Solution:**

```bash
bash ./install.sh
```

### Scripts stop unexpectedly

**Diagnosis:**

1. Read the error message and check `~/.ubuntu-setup-install.log`
2. Note which step failed (for example, "Installing Neovim failed")
3. Run the individual module to reproduce:

   ```bash
   ./library_scripts/install-neovim.sh
   ```

**Recovery:** Fix the issue, then re-run `./install.sh` (modules are idempotent).

## Tool-Specific Issues

### tmux

```bash
chmod +x library_scripts/install-tmux.sh
sudo apt-get update
./library_scripts/install-tmux.sh
```

### Fish shell

Fish is default-on (`INSTALL_FISH=true`); set `INSTALL_FISH=false` to skip it.

```bash
sudo apt-get remove fish
./library_scripts/install-fish.sh
chsh -s /usr/bin/fish
```

### Zsh

Zsh is opt-in (`INSTALL_ZSH=false` by default) — set `INSTALL_ZSH=true` before
running `install.sh`, or run its module directly:

```bash
sudo apt-get remove zsh
INSTALL_ZSH=true ./library_scripts/install-zsh.sh
chsh -s /usr/bin/zsh
```

If `chsh` fails with "not listed in /etc/shells", re-run
`sudo apt-get install --reinstall zsh` (installing the package registers it
there automatically).

### Bash

Bash itself is never installed or removed (it's Ubuntu's default), but its
prompt/PATH/NVM setup is always applied idempotently and can be re-run any
time:

```bash
./library_scripts/install-bash-enhancements.sh
```

To remove the oh-my-posh/PATH/NVM lines it adds, edit `~/.bashrc` manually —
`uninstall.sh` never touches shell rc file contents, only removes packages.

### Neovim

Neovim is downloaded from the official GitHub release (not apt), since apt's
version varies by distro/architecture and is often too old for plugin
managers like lazy.nvim (requires >= 0.8.0).

```bash
./library_scripts/install-neovim.sh
ls -la ~/.local/opt/nvim   # extracted release
ls -la ~/.local/bin/nvim   # symlink to the binary
nvim --version
```

If `nvim --version` shows an old version, another `nvim` earlier in your
`PATH` (e.g. an apt-installed one from `/usr/bin`) is shadowing it — check
with `which -a nvim` and ensure `~/.local/bin` comes first in `PATH`.

```bash
ls ~/.config/nvim
./library_scripts/setup-dotfiles.sh
```

### Node.js / NVM

Node is installed via NVM, not apt.

```bash
source ~/.nvm/nvm.sh
nvm install --lts
node --version
```

If NVM is missing:

```bash
./library_scripts/install-nvm.sh
```

### fzf

```bash
export PATH="$HOME/.fzf/bin:$PATH"
~/.fzf/bin/fzf --version
./library_scripts/install-fzf.sh
```

On ARM systems, fzf downloads the correct `linux_arm64` binary automatically.

### Terraform (optional)

```bash
INSTALL_TERRAFORM=true ./install.sh
# or
./library_scripts/install-terraform.sh
terraform --version
```

### Nebius CLI (optional)

```bash
INSTALL_NEBIUS_CLI=true ./install.sh
# or
./library_scripts/install-nebius-cli.sh
nebius configure
```

## Dotfiles Issues

### Clone fails

**Problem:** `fatal: repository not found` or authentication errors

**Solutions:**

1. Override the repo URL: `DOTFILES_REPO=https://github.com/you/dotfiles.git ./install.sh`
2. For private repos, configure SSH keys and test with `ssh -T git@github.com`
3. To continue without dotfiles: `DOTFILES_OPTIONAL=true ./install.sh`

## System-Level Issues

### Insufficient disk space

```bash
df -h
sudo apt-get clean
sudo apt-get autoremove
```

### Network issues

```bash
curl -I https://github.com
nslookup github.com
```

### Sudo password prompts

```bash
sudo -v
./install.sh
```

## Development / CI

Run smoke tests locally:

```bash
./scripts/ci-smoke.sh
```

## Collecting debug information

```bash
uname -a
lsb_release -a
cat ~/.ubuntu-setup-install.log
dpkg -l | grep -E 'tmux|fish|neovim|terraform'
df -h
```
