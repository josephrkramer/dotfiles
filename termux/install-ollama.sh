#!/bin/bash
set -euo pipefail

install_ollama() {
  pkg install -y ollama
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_ollama
fi
