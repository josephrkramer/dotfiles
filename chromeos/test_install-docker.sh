#!/bin/bash
set -euo pipefail

# Set USER if it is unbound to prevent failure in install_docker
export USER="${USER:-testuser}"

# Create mock directory
MOCK_DIR=$(mktemp -d)
trap 'rm -rf "$MOCK_DIR"' EXIT
export PATH="$MOCK_DIR:$PATH"

# Create mock for sudo
cat > "$MOCK_DIR/sudo" << 'MOCK'
#!/bin/bash
echo "mock sudo: $@" >&2
MOCK
chmod +x "$MOCK_DIR/sudo"

# Source the script
source chromeos/install-docker.sh

# Call the function
install_docker

echo "test_install-docker.sh passed"
