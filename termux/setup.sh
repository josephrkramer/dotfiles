#!/bin/bash
set -euo pipefail

setup_termux() {
  HEADLESS=1
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --gui)
        HEADLESS=0
        shift # past argument
        ;;
      *)
        # unknown option
        shift # past argument
        ;;
    esac
  done

  # setup github (installs git as dependency)
  ./install-gh-cli.sh
  gh auth login

  # setup local git
  ./set_git_config.sh

  # install vscode (code-server)
  if [ "$HEADLESS" -eq 0 ]; then
    ./install-vscode.sh
  fi

  # install nodejs
  ./install-node.sh

  # install gemini cli
  ./install-gemini.sh

  # install antigravity
  if [ "$HEADLESS" -eq 0 ]; then
    ./install-antigravity.sh || true
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_termux "$@"
fi