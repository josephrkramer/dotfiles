#!/bin/bash
set -euo pipefail

install_gh_cli() {
  echo "Starting install-gh-cli.sh..."
  pkg update
  pkg install -y gh
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_gh_cli
fi