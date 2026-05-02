#!/bin/bash
set -euo pipefail

install_antigravity() {
  echo "Starting install-antigravity.sh..."
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/antigravity-repo-key.gpg
  echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | \
    sudo tee /etc/apt/sources.list.d/antigravity.list > /dev/null

  sudo apt update
  sudo apt install -y antigravity
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_antigravity
fi
  
