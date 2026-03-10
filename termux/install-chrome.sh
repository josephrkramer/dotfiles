#!/bin/bash
set -euo pipefail

install_chrome() {
  echo "Google Chrome is not natively supported on Termux without proot/qemu."
  return 1
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_chrome
fi