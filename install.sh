#!/bin/bash
set -euo pipefail

install_dotfiles() {
  echo "Starting dotfiles install script..."

  # --- Install Google Gemini CLI ---

  # Check if nvm is installed, if not, install it
  if [ ! -d "$HOME/.nvm" ]; then
    echo "Installing nvm..."
    local nvm_script
    nvm_script=$(mktemp)
    trap 'rm -f "$nvm_script"' EXIT
    curl -sS -o "$nvm_script" https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh
    bash "$nvm_script"
    rm -f "$nvm_script" # Clean up on success
    trap - EXIT # Remove the trap
  fi

  # Source nvm script to make nvm command available
  export NVM_DIR="/usr/local/share/nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

  # Install Node.js v22 (or v18+) and set as default
  # Gemini CLI requires Node 18+
  if ! nvm ls 22 > /dev/null 2>&1; then
    echo "Installing Node.js v22..."
    nvm install 22
    nvm use 22
    nvm alias default 22
  fi

  # Install Gemini CLI globally using npm
  if ! command -v gemini > /dev/null 2>&1; then
    echo "Installing @google/gemini-cli..."
    npm install -g @google/gemini-cli
    echo "Gemini CLI installed successfully."
  else
    echo "Gemini CLI is already installed."
  fi

  echo "Dotfiles install script finished."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_dotfiles
fi