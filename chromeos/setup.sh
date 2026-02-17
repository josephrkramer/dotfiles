#!/bin/bash
set -euo pipefail

# install btop first so progress can be monitored for the rest of the setup
./install-btop.sh

# setup local git
./set_git_config.sh

# setup github
./install-gh-cli.sh
gh auth login

# install vscode
./install-vscode.sh

# install nodejs
./install-node.sh

# Source nvm script so node and npm are available for subsequent steps
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# install gemini cli
./install-gemini.sh

# install antigravity
./install-antigravity.sh

# install chrome (required for antigravity agent browser)
#./install-chrome.sh
