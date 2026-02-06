#!/bin/bash

# Script to install opencode configuration files to ~/.config/opencode
# This script copies the commands folder and opencode.json to the config directory

set -e

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/opencode"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Installing opencode configuration..."
echo "Source: $SCRIPT_DIR"
echo "Destination: $CONFIG_DIR"
echo ""

# Create config directory if it doesn't exist
if [ ! -d "$CONFIG_DIR" ]; then
    echo -e "${YELLOW}Creating directory: $CONFIG_DIR${NC}"
    mkdir -p "$CONFIG_DIR"
fi

# Check if source files exist
if [ ! -d "$SCRIPT_DIR/commands" ]; then
    echo -e "${RED}Error: commands folder not found in $SCRIPT_DIR${NC}"
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/opencode.json" ]; then
    echo -e "${RED}Error: opencode.json not found in $SCRIPT_DIR${NC}"
    exit 1
fi

# Backup existing files if they exist
if [ -d "$CONFIG_DIR/commands" ]; then
    echo -e "${YELLOW}Backing up existing commands folder to commands.backup${NC}"
    rm -rf "$CONFIG_DIR/commands.backup"
    mv "$CONFIG_DIR/commands" "$CONFIG_DIR/commands.backup"
fi

if [ -f "$CONFIG_DIR/opencode.json" ]; then
    echo -e "${YELLOW}Backing up existing opencode.json to opencode.json.backup${NC}"
    rm -f "$CONFIG_DIR/opencode.json.backup"
    mv "$CONFIG_DIR/opencode.json" "$CONFIG_DIR/opencode.json.backup"
fi

# Copy files
echo "Copying commands folder..."
cp -r "$SCRIPT_DIR/commands" "$CONFIG_DIR/commands"

echo "Copying opencode.json..."
cp "$SCRIPT_DIR/opencode.json" "$CONFIG_DIR/opencode.json"

# Prompt for Context7 API key
echo ""
echo -e "${YELLOW}Context7 MCP Configuration${NC}"
echo "Context7 provides documentation lookup for libraries and frameworks."
echo "Get your API key at: https://context7.com"
echo ""
read -p "Enter your CONTEXT7_API_KEY (or press Enter to skip): " CONTEXT7_KEY

if [ -n "$CONTEXT7_KEY" ]; then
    # Detect shell configuration file
    SHELL_CONFIG=""
    if [ -f "$HOME/.zshrc" ]; then
        SHELL_CONFIG="$HOME/.zshrc"
    elif [ -f "$HOME/.bashrc" ]; then
        SHELL_CONFIG="$HOME/.bashrc"
    elif [ -f "$HOME/.bash_profile" ]; then
        SHELL_CONFIG="$HOME/.bash_profile"
    fi

    if [ -n "$SHELL_CONFIG" ]; then
        # Check if CONTEXT7_API_KEY already exists in shell config
        if grep -q "export CONTEXT7_API_KEY=" "$SHELL_CONFIG" 2>/dev/null; then
            echo -e "${YELLOW}Updating existing CONTEXT7_API_KEY in $SHELL_CONFIG${NC}"
            # Use sed to replace existing value (macOS compatible)
            sed -i '' "s|export CONTEXT7_API_KEY=.*|export CONTEXT7_API_KEY=\"$CONTEXT7_KEY\"|" "$SHELL_CONFIG"
        else
            echo -e "${GREEN}Adding CONTEXT7_API_KEY to $SHELL_CONFIG${NC}"
            echo "" >> "$SHELL_CONFIG"
            echo "# Context7 API Key for opencode" >> "$SHELL_CONFIG"
            echo "export CONTEXT7_API_KEY=\"$CONTEXT7_KEY\"" >> "$SHELL_CONFIG"
        fi
        echo -e "${YELLOW}Run 'source $SHELL_CONFIG' or restart your terminal to apply changes${NC}"
    else
        echo -e "${YELLOW}Could not detect shell config file.${NC}"
        echo "Add this to your shell profile manually:"
        echo "  export CONTEXT7_API_KEY=\"$CONTEXT7_KEY\""
    fi
else
    echo -e "${YELLOW}Skipped Context7 API key configuration.${NC}"
    echo "You can set it later by adding to your shell profile:"
    echo "  export CONTEXT7_API_KEY=\"your-api-key\""
fi

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "Installed files:"
echo "  - $CONFIG_DIR/opencode.json"
echo "  - $CONFIG_DIR/commands/"
ls -la "$CONFIG_DIR/commands/"
