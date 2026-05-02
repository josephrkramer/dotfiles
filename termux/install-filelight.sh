#!/bin/bash
set -euo pipefail

install_filelight() {
  echo "Starting install-filelight.sh..."
  echo "Filelight (GUI) is not supported. Use terminal tools like ncdu."
  return 1
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_filelight
fi