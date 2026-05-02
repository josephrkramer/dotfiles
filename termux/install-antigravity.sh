#!/bin/bash
set -euo pipefail

install_antigravity() {
  echo "Starting install-antigravity.sh..."
  echo "Antigravity deb repository is incompatible with Termux (requires glibc)."
  return 1
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_antigravity
fi