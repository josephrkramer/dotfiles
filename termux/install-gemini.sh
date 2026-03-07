#!/bin/bash
set -euo pipefail

install_gemini() {
  echo "Starting Gemini install script..."

  # --- Install Google Gemini CLI ---

  # Install Gemini CLI globally using npm
  if ! command -v gemini > /dev/null; then
    echo "Installing @google/gemini-cli..."
    npm install -g @google/gemini-cli
    echo "Gemini CLI installed successfully."
  else
    echo "Gemini CLI is already installed."
  fi

  echo "Gemini CLI install script finished."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_gemini
fi