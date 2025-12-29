# Installation Guide

## Prerequisites

- Ubuntu 18.04 LTS or newer
- Sudo/root access
- Internet connection
- Git installed
- At least 2GB free disk space

## Before You Start

1. **Backup Important Data** - Ensure you have backups before system modifications
2. **Review the Scripts** - Check `src/` scripts to understand what will be installed
3. **Prepare GitHub Access** - If dotfiles are private, ensure GitHub credentials are configured
4. **Check Disk Space** - Run `df -h` to verify available space

## Installation Steps

### Step 1: Clone the Repository

```bash
git clone https://github.com/omoinjm/ubuntu-setup.git
cd ubuntu-setup
```

### Step 2: Review the Main Script

```bash
cat install.sh
```

Review the installation sequence and understand what each step does.

### Step 3: Make Scripts Executable

```bash
chmod +x install.sh
chmod +x src/*.sh
```

### Step 4: Run the Installation

```bash
./install.sh
```

The script will:
- Prompt for sudo password if needed
- Display progress messages
- Stop immediately if any installation fails
- Print "Setup complete." on success

### Step 5: Verify Installation

After successful completion, verify all tools are installed:

```bash
tmux -V
fish --version
nvim --version
node --version
terraform --version
nebius --version
```

## Installation Time

Typical installation takes 10-30 minutes depending on:
- Internet connection speed
- System resources
- Number of packages to download
- Existing dependencies

## Troubleshooting

### Script Permission Denied
```bash
chmod +x install.sh src/*.sh
```

### Installation Fails

See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for common issues and solutions.

### Partial Installation

If installation stops partway through:
1. Note which step failed
2. Check the error message
3. Refer to [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
4. Rerun `./install.sh` after fixing the issue

## Uninstalling

To uninstall specific tools:

```bash
# Remove tmux
sudo apt-get remove tmux

# Remove Fish shell
sudo apt-get remove fish

# Remove Neovim
sudo apt-get remove neovim

# Remove Node.js
sudo apt-get remove nodejs npm

# Remove Terraform
sudo apt-get remove terraform
```

To remove the nebius CLI, see its documentation.

## Post-Installation

1. **Configure Fish Shell** - Set as default shell:
   ```bash
   chsh -s /usr/bin/fish
   ```

2. **Set Up tmux** - Copy tmux config from dotfiles

3. **Configure Neovim** - Init.vim should be pulled from dotfiles

4. **Test Environment** - Create a test project to verify everything works
