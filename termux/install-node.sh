#!/bin/bash
set -euo pipefail

install_node() {
  echo "Starting install-node.sh..."

  pkg update
  pkg install -y nodejs

  echo "Node.js install script finished."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_node
fi