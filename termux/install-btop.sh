#!/bin/bash
set -euo pipefail

install_btop() {
  pkg update
  pkg install -y btop
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_btop
fi