#!/bin/bash
set -euo pipefail

install_vscode() {
  echo "Starting install-vscode.sh..."
  echo "Installing code-server (VS Code for Termux)..."
  pkg update
  pkg install -y tur-repo
  pkg install -y code-server
  echo "code-server installed successfully."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_vscode
fi