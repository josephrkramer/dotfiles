#!/bin/bash
set -euo pipefail

install_gemini() {
  echo "Starting Gemini install script..."

  # --- Install Google Gemini CLI ---

  # Install Gemini CLI globally using npm
  if ! command -v gemini > /dev/null; then
    echo "Installing build dependencies for native modules..."
    pkg install -y python make clang
    echo "Installing @google/gemini-cli..."
    mkdir -p ~/.gyp && echo "{'variables':{'android_ndk_path':''}}" > ~/.gyp/include.gypi
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