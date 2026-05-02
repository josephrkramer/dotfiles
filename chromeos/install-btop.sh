#!/bin/bash
set -euo pipefail

install_btop() {
  echo "Starting install-btop.sh..."
  sudo apt update
  sudo apt install -y btop
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_btop
fi
