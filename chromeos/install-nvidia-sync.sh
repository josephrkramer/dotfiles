#!/bin/bash
set -euo pipefail

install_nvidia_sync() {
  echo "Starting install-nvidia-sync.sh..."
  sudo curl -fsSL https://workbench.download.nvidia.com/stable/linux/gpgkey -o /etc/apt/trusted.gpg.d/ai-workbench-desktop-key.asc
  echo "deb https://workbench.download.nvidia.com/stable/linux/debian default proprietary" | sudo tee -a /etc/apt/sources.list > /dev/null
  sudo apt update
  sudo apt install -y nvidia-sync
  echo "NVIDIA Sync installation finished."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_nvidia_sync
fi
