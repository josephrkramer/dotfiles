#!/bin/bash
set -euo pipefail

setup_chromeos() {
  HEADLESS=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --headless)
        HEADLESS=1
        shift # past argument
        ;;
      *)
        # unknown option
        shift # past argument
        ;;
    esac
  done

  # install btop first so progress can be monitored for the rest of the setup
  ./install-btop.sh

  # setup local git
  ./set_git_config.sh

  # setup github
  ./install-gh-cli.sh
  gh auth login

  # install vscode
  if [ "$HEADLESS" -eq 0 ]; then
    ./install-vscode.sh
  fi

  # install nodejs
  ./install-node.sh

  # Source nvm script so node and npm are available for subsequent steps
  export NVM_DIR="$HOME/.config/nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

  # install gemini cli
  ./install-gemini.sh

  # install opencode
  ./install-opencode.sh

  # install antigravity
  if [ "$HEADLESS" -eq 0 ]; then
    ./install-antigravity.sh
  fi

  # install chrome (required for antigravity agent browser)
  #./install-chrome.sh
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_chromeos "$@"
fi
