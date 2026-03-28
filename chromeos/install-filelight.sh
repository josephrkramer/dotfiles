#!/bin/bash
set -euo pipefail

install_filelight() {
  # disk usage analyzer
  sudo apt update
  sudo apt install -y filelight
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_filelight
fi
