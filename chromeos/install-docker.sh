#!/bin/bash
set -euo pipefail

install_docker() {
  echo "Starting install-docker.sh..."

  # Add Docker's official GPG key:
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Add the repository to Apt sources:
  # The environment may be Ubuntu masquerading as Debian or vice versa, so we check for ubuntu vs debian.
  local OS_ID
  OS_ID=$(. /etc/os-release && echo "$ID")
  sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/${OS_ID}
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

  sudo apt-get update

  # Install Docker packages:
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  # Add the current user to the docker group
  sudo usermod -aG docker "$USER"

  echo
  echo "User '$USER' has been added to the 'docker' group."
  echo "You must log out and log back in for this change to take effect."

  echo "Docker installation finished."

  echo
  echo "Try the command 'docker run hello-world' to test the installation"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_docker
fi
