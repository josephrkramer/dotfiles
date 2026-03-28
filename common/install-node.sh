#!/bin/bash
set -euo pipefail

install_node() {
  echo "Starting nvm/Node.js install script..."

  # Set NVM_DIR to define the installation directory for nvm.
  export NVM_DIR="${NVM_DIR:-$HOME/.config/nvm}"

  # Check if nvm is installed, if not, install it
  if [ ! -d "$NVM_DIR" ]; then
    echo "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  fi

  # Source nvm script to make nvm command available
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

  # Install Node.js v22 (or v18+) and set as default
  # Gemini CLI requires Node 18+
  if ! nvm ls "${NODE_VERSION_TO_INSTALL:-22}" > /dev/null 2>&1; then
    echo "Installing Node.js v${NODE_VERSION_TO_INSTALL:-22}..."
    nvm install "${NODE_VERSION_TO_INSTALL:-22}"
    nvm use "${NODE_VERSION_TO_INSTALL:-22}"
    nvm alias default "${NODE_VERSION_TO_INSTALL:-22}"
  fi

  echo "nvm/Node.js install script finished."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_node
fi
