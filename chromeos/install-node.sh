#!/bin/bash
set -euo pipefail

. "$(dirname "${BASH_SOURCE[0]}")/../common/install-node.sh"

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_node
fi