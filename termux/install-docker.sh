#!/bin/bash
set -euo pipefail

install_docker() {
  echo "Starting install-docker.sh..."
  echo "Docker is not natively supported on Termux without proot/qemu and custom kernels."
  return 1
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_docker
fi