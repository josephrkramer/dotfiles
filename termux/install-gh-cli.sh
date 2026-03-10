#!/bin/bash
set -euo pipefail

install_gh_cli() {
  pkg update
  pkg install -y gh
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_gh_cli
fi