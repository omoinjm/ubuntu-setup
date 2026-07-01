# Installation Guide

## Prerequisites

- Ubuntu 18.04 LTS or newer
- Sudo/root access
- Internet connection
- curl and git
- At least 2GB free disk space

## Before You Start

1. **Backup important data** before system modifications
2. **Review the scripts** in `library_scripts/` to see what will be installed
3. **Prepare GitHub access** if dotfiles are private (SSH key or HTTPS credentials)
4. **Check disk space** with `df -h`

## Installation Steps

### Step 1: Clone the repository

```bash
git clone https://github.com/omoinjm/ubuntu-setup.git
cd ubuntu-setup
```

### Step 2: Review the main script

```bash
cat install.sh
```

### Step 3: Make scripts executable

```bash
chmod +x install.sh uninstall.sh library_scripts/*.sh scripts/ci-smoke.sh
```

### Step 4: Run pre-flight checks (optional)

```bash
./library_scripts/check-prerequisites.sh
```

### Step 5: Run the installation

```bash
./install.sh
```

With optional tools:

```bash
INSTALL_TERRAFORM=true INSTALL_NEBIUS_CLI=true ./install.sh
```

Custom dotfiles repository:

```bash
DOTFILES_REPO=https://github.com/you/your-dotfiles.git ./install.sh
```

The script will:

- Prompt for sudo password when needed
- Display color-coded progress
- Stop immediately if a required step fails
- Write a log to `~/.ubuntu-setup-install.log`

### Step 6: Verify installation

```bash
tmux -V
fish --version
nvim --version
nvm --version
node --version
~/.fzf/bin/fzf --version
```

Optional tools:

```bash
terraform --version    # if INSTALL_TERRAFORM=true
nebius --version       # if INSTALL_NEBIUS_CLI=true
dotnet --version       # if INSTALL_DOTNET=true
```

## Installation Time

Typical installation takes 10–30 minutes depending on network speed, system resources, and how many packages are already present.

## Troubleshooting

### Script permission denied

```bash
chmod +x install.sh library_scripts/*.sh
```

### Installation fails

See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md).

### Partial installation

1. Note which step failed
2. Check `~/.ubuntu-setup-install.log`
3. Fix the underlying issue
4. Re-run `./install.sh` (modules are idempotent)

## Uninstalling

```bash
./uninstall.sh
```

This removes installed tools but preserves config directories and dotfiles unless you delete them manually.

## Post-Installation

1. **Set Fish as default shell:**

   ```bash
   chsh -s /usr/bin/fish
   ```

2. **Log out and back in** for shell and PATH changes to apply

3. **Review dotfiles** at `~/.dotfiles`

4. **Run CI smoke tests** when developing:

   ```bash
   ./scripts/ci-smoke.sh
   ```
