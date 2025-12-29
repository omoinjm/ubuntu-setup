# Troubleshooting Guide

Common issues and solutions when using the ubuntu-setup installation script.

## Installation Script Issues

### Permission Denied Error

**Problem:** `bash: ./install.sh: Permission denied`

**Solution:**
```bash
chmod +x install.sh src/*.sh
./install.sh
```

### Command Not Found

**Problem:** `./install.sh: command not found`

**Cause:** Script being run with wrong interpreter

**Solution:**
```bash
bash ./install.sh
# or
chmod +x install.sh
./install.sh
```

### Scripts Stop Unexpectedly

**Problem:** Installation stops at a certain step

**Diagnosis:**
1. Read the error message carefully
2. Note which script failed (e.g., "Failed to install tmux")
3. Check the specific troubleshooting section below

**Recovery:**
```bash
# Fix the identified issue
# Then rerun the full script
./install.sh
```

## Tool-Specific Issues

### tmux Installation Fails

**Problem:** `sudo: unable to execute ./src/install-tmux.sh: Permission denied`

**Solution:**
```bash
chmod +x src/install-tmux.sh
./install.sh
```

**Problem:** `E: Unable to locate package tmux`

**Solution:**
```bash
sudo apt-get update
./install.sh
```

### Fish Shell Installation Issues

**Problem:** `fish: command not found` after installation

**Cause:** Fish not in PATH or installation incomplete

**Solution:**
```bash
# Reinstall fish
sudo apt-get remove fish
./src/install-fish.sh

# Add to PATH if needed
export PATH="/usr/bin/fish:$PATH"
```

**Problem:** Want to use Fish as default shell

**Solution:**
```bash
chsh -s /usr/bin/fish
# Logout and login for changes to take effect
```

### Neovim Installation Issues

**Problem:** `command not found: nvim`

**Solution:**
```bash
sudo apt-get update
sudo apt-get install -y neovim
```

**Problem:** Plugins not loading

**Cause:** Configuration file missing or incorrect location

**Solution:**
```bash
# Check if config exists
ls ~/.config/nvim/init.vim

# If missing, should be in dotfiles
# Ensure setup-dotfiles.sh ran successfully
./src/setup-dotfiles.sh
```

### Node.js Installation Issues

**Problem:** `node: command not found` after installation

**Solution:**
```bash
# Check installation
npm --version
node --version

# If not found, reinstall
sudo apt-get remove nodejs npm
./src/install-nodejs.sh
```

**Problem:** npm permission issues when installing packages

**Solution:**
```bash
# Fix npm permissions
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
export PATH=~/.npm-global/bin:$PATH
```

### Terraform Installation Issues

**Problem:** `terraform: command not found`

**Solution:**
```bash
# Verify installation
terraform --version

# If not installed
./src/install-terraform.sh

# Check PATH
echo $PATH | grep terraform
```

**Problem:** Terraform not in PATH

**Solution:**
```bash
# Add terraform location to PATH
export PATH="/usr/local/bin:$PATH"

# Make permanent by adding to shell config
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
```

### Nebius CLI Issues

**Problem:** `nebius: command not found`

**Solution:**
```bash
# Check if installation succeeded
which nebius

# Reinstall
./src/install-nebius-cli.sh
```

**Problem:** Authentication errors with Nebius

**Cause:** Credentials not configured

**Solution:**
```bash
nebius configure
# Follow prompts to enter credentials
```

## Dotfiles Issues

### Dotfiles Clone Fails

**Problem:** `fatal: repository not found`

**Cause:** GitHub repository URL incorrect or inaccessible

**Solution:**
1. Verify the dotfiles repository URL is correct
2. Ensure you have access to the repository
3. Check internet connection
4. For private repos, ensure SSH keys are configured:
   ```bash
   ssh-keyscan github.com >> ~/.ssh/known_hosts
   ```

**Problem:** Permission denied (publickey)

**Cause:** SSH key not configured or incorrect

**Solution:**
```bash
# Generate SSH key if needed
ssh-keygen -t ed25519 -C "your-email@example.com"

# Add to GitHub at https://github.com/settings/keys

# Test connection
ssh -T git@github.com
```

## System-Level Issues

### Insufficient Disk Space

**Problem:** `No space left on device`

**Diagnosis:**
```bash
df -h
du -sh ~/
```

**Solution:**
1. Free up disk space
2. Remove unnecessary packages: `sudo apt-get clean`
3. Remove old kernels: `sudo apt-get autoremove`
4. Retry installation

### Sudo Password Prompts

**Problem:** Repeated password prompts during installation

**Cause:** Normal behavior - password needed for package installation

**Solution:** Enter your password when prompted. To avoid repeated prompts:
```bash
sudo -v  # Update sudo credentials
./install.sh  # Run immediately after
```

### Network Connection Issues

**Problem:** Installation hangs or times out

**Cause:** Network connectivity problems or package repository down

**Solution:**
```bash
# Check internet connection
ping 8.8.8.8

# Check DNS
nslookup github.com

# Use different package mirror if apt is slow
sudo nano /etc/apt/sources.list  # Change to different mirror
```

## Getting Help

If issues persist:

1. **Check logs** - Review output from the failed script
2. **Search online** - Error message often leads to solutions
3. **Check tool documentation** - Visit official docs for the failing tool
4. **Create an issue** - Report reproducible problems

### Collecting Debug Information

```bash
# Get system info
uname -a
lsb_release -a

# Check Ubuntu version
cat /etc/ubuntu-release

# List installed packages
dpkg -l | grep -E 'tmux|fish|neovim|nodejs|terraform'

# Check available disk space
df -h
```
