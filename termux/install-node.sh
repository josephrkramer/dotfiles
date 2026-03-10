#!/bin/bash
set -euo pipefail

install_node() {
  echo "Starting Node.js install script..."

  pkg update
  pkg install -y nodejs

  echo "Node.js install script finished."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_node
fi