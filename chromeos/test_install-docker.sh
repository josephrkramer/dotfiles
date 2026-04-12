#!/bin/bash
set -euo pipefail

# Create mock directory
MOCK_DIR=$(mktemp -d)
trap 'rm -rf "$MOCK_DIR"' EXIT
export PATH="$MOCK_DIR:$PATH"

# Create mock for sudo that logs calls
SUDO_LOG="$MOCK_DIR/sudo.log"
cat > "$MOCK_DIR/sudo" << 'MOCK'
#!/bin/bash
echo "$@" >> "$SUDO_LOG"
MOCK
chmod +x "$MOCK_DIR/sudo"

# Source the script
source chromeos/install-docker.sh

# Call the function
install_docker

echo "test_install-docker.sh passed"
