#!/bin/bash
set -euo pipefail

install_opencode() {
  echo "Starting OpenCode install script..."

  # --- Install OpenCode CLI ---

  # Install OpenCode CLI globally using npm
  if ! command -v opencode > /dev/null; then
    echo "Installing opencode-ai..."
    npm install -g opencode-ai
    echo "OpenCode CLI installed successfully."
  else
    echo "OpenCode CLI is already installed."
  fi

  echo "OpenCode CLI install script finished."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_opencode
fi
