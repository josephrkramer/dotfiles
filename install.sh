#!/bin/bash
set -e

echo "Starting dotfiles install script..."

# --- Install Google Gemini CLI ---

# Install NVM and Node.js
export NVM_DIR="/usr/local/share/nvm"
. "$(dirname "${BASH_SOURCE[0]}")/common/install-node.sh"
install_node

# Install Gemini CLI globally using npm
if ! command -v gemini > /dev/null; then
  echo "Installing @google/gemini-cli..."
  npm install -g @google/gemini-cli
  echo "Gemini CLI installed successfully."
else
  echo "Gemini CLI is already installed."
fi

echo "Dotfiles install script finished."