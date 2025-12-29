# Adding New Modules

This guide explains how to add new installation modules to the setup script.

## Module Structure

Each module is a shell script in the `src/` directory following this naming convention:

```
src/install-<toolname>.sh
```

## Template for New Modules

```bash
#!/bin/bash

# Script: install-example.sh
# Purpose: Install and configure example tool
# Exit codes: 0 = success, 1 = failure

set -e  # Exit on error

TOOL_NAME="example-tool"

echo "Installing $TOOL_NAME..."

# Step 1: Check prerequisites
if ! command -v git &> /dev/null; then
    echo "Error: Git is required but not installed."
    exit 1
fi

# Step 2: Install the package
sudo apt-get update -qq
sudo apt-get install -y example-tool

# Step 3: Configure (if needed)
mkdir -p ~/.config/example-tool
# Copy configuration files or run setup commands

# Step 4: Verify installation
if ! command -v example-tool &> /dev/null; then
    echo "Error: $TOOL_NAME installation verification failed."
    exit 1
fi

echo "✓ $TOOL_NAME installed successfully"
exit 0
```

## Step-by-Step: Add a New Tool

### 1. Create the Script File

```bash
touch src/install-mynewtools.sh
chmod +x src/install-mynewtools.sh
```

### 2. Write the Script

Follow the template above:
- Add a shebang (`#!/bin/bash`)
- Include a comment header with purpose
- Use `set -e` to exit on error
- Include prerequisite checks
- Perform installation
- Verify the installation
- Return appropriate exit code

### 3. Update Main install.sh

Add your module to `install.sh`:

```bash
# Install mynewtools
echo "Running mynewtools installation script..."
if ! ./src/install-mynewtools.sh; then
    echo "Failed to install mynewtools. Exiting."
    exit 1
fi
```

Insert this in the appropriate logical location in the script.

### 4. Update Documentation

Update `docs/ARCHITECTURE.md`:
- Add your tool to the directory structure
- Add it to the execution flow diagram

Update `docs/OVERVIEW.md`:
- Add your tool to the "What It Does" section

### 5. Test the New Module

Test your new script in isolation:

```bash
./src/install-mynewtools.sh
```

Then test the full installation process:

```bash
./install.sh
```

## Best Practices

### Error Handling
- Check for prerequisites before installation
- Validate installation with version checks or command availability
- Provide clear error messages
- Use appropriate exit codes

### User Feedback
- Echo progress messages
- Show tool version after installation
- Indicate success with clear completion message

### Compatibility
- Use only Ubuntu/Debian compatible package managers
- Support Ubuntu LTS versions (18.04, 20.04, 22.04+)
- Check for existing installations before reinstalling

### Minimal Changes
- Only install what's necessary
- Don't modify system files unnecessarily
- Keep configuration in user home directory when possible

## Common Patterns

### Install from apt Repository
```bash
sudo apt-get update -qq
sudo apt-get install -y package-name
```

### Install from npm
```bash
npm install -g package-name
```

### Install from source/binary
```bash
curl -fsSL https://example.com/installer.sh | bash
```

### Configure with Dotfiles
```bash
# If configuration is in dotfiles repo
mkdir -p ~/.config/tool-name
# Link or copy config from dotfiles
```

## Module Dependencies

If your module depends on another tool:

1. Add a prerequisite check at the start
2. Note the dependency in comments
3. Consider reordering `install.sh` to install dependencies first

Example:
```bash
# Check that Git is installed (installed by setup-dotfiles.sh)
if ! command -v git &> /dev/null; then
    echo "Error: Git is required. Run setup-dotfiles.sh first."
    exit 1
fi
```

## Testing Checklist

- [ ] Script runs without errors
- [ ] Tool is installed in expected location
- [ ] Version command works (`tool --version`)
- [ ] Configuration is applied correctly
- [ ] Script returns exit code 0 on success
- [ ] Script returns exit code 1 on failure
- [ ] Error messages are clear and helpful
- [ ] Works on clean Ubuntu install
