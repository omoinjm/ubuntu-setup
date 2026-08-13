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

### Step 5: Preview the install plan (optional)

```bash
./install.sh --show-plan
```

This prints the planned steps, apt packages, PPAs, and downloads without making any changes.

### Step 6: Run the installation

```bash
./install.sh
```

With optional tools:

```bash
INSTALL_ZSH=true INSTALL_TERRAFORM=true INSTALL_NEBIUS_CLI=true ./install.sh
```

Fish is installed by default; skip it with `INSTALL_FISH=false ./install.sh`. bash is always enhanced (oh-my-posh, PATH, NVM sourcing) regardless of these flags.

Custom dotfiles repository:

```bash
DOTFILES_REPO=https://github.com/you/your-dotfiles.git ./install.sh
```

The script will:

- Print an install plan summary before making changes (unless `SHOW_INSTALL_PLAN=false`)
- Prompt for sudo password when needed
- Display color-coded progress with elapsed-time spinners (unless `DISABLE_SPINNER=true`)
- Print each command as it runs (unless `SHOW_INSTALL_COMMANDS=false`)
- Use `pv` for download progress bars when available (unless `INSTALL_PV=false`)
- Stop immediately if a required step fails
- Write a log to `~/.ubuntu-setup-install.log`

### Step 7: Verify installation

```bash
tmux -V
bash --version
fish --version          # if INSTALL_FISH=true (default)
nvim --version
nvm --version
node --version
~/.fzf/bin/fzf --version
```

Optional tools:

```bash
zsh --version           # if INSTALL_ZSH=true
terraform --version    # if INSTALL_TERRAFORM=true
nebius --version       # if INSTALL_NEBIUS_CLI=true
dotnet --version       # if INSTALL_DOTNET=true
```

## Configuration

Environment variables (see `library_scripts/config.sh`):

| Variable | Default | Description |
|----------|---------|-------------|
| `DOTFILES_REPO` | `https://github.com/omoinjm/.dotfiles.git` | Dotfiles HTTPS URL |
| `DOTFILES_OPTIONAL` | `false` | Continue if dotfiles clone fails |
| `INSTALL_PV` | `true` | Install `pv` for enhanced download progress bars |
| `INSTALL_FISH` | `true` | Install and configure Fish shell |
| `INSTALL_ZSH` | `false` | Install and configure Zsh shell |
| `INSTALL_TERRAFORM` | `false` | Install Terraform |
| `INSTALL_NEBIUS_CLI` | `false` | Install Nebius CLI |
| `INSTALL_DOTNET` | `false` | Install .NET SDK |
| `SHOW_INSTALL_PLAN` | `true` | Print package/step summary before installing |
| `SHOW_INSTALL_COMMANDS` | `true` | Print each shell command as it runs |
| `DISABLE_SPINNER` | `false` | Disable animated progress spinners (auto-disabled in CI) |

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

1. **Set your preferred shell as default** (bash needs no `chsh`, it's already enhanced automatically):

   ```bash
   chsh -s /usr/bin/fish   # if INSTALL_FISH=true (default)
   chsh -s /usr/bin/zsh    # if INSTALL_ZSH=true
   ```

2. **Log out and back in** for shell and PATH changes to apply

3. **Review dotfiles** at `~/.dotfiles` (configs under `home/.config/`, linked into `~/.config`)

4. **Copy secret templates** from `~/.dotfiles/secrets/` if needed (see dotfiles `secrets/README.md`)

5. **Run CI smoke tests** when developing:

   ```bash
   ./scripts/ci-smoke.sh
   ```
