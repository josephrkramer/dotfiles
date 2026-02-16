#!/bin/bash
set -euo pipefail

# --- Install Google Gemini CLI ---

# Install Gemini CLI globally using npm
if ! command -v gemini > /dev/null; then
  echo "Installing @google/gemini-cli..."
  npm install -g @google/gemini-cli
  echo "Gemini CLI installed successfully."
else
  echo "Gemini CLI is already installed."
fi

echo "Dotfiles install script finished."