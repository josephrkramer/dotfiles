#!/bin/bash
set -euo pipefail

# Create a temporary directory for mock commands
MOCK_DIR=$(mktemp -d)

# Ensure the mock directory is removed upon script exit
trap 'rm -rf "$MOCK_DIR"' EXIT

# Create a mock for 'sudo'
cat << 'EOF' > "$MOCK_DIR/sudo"
#!/bin/bash
# Mock sudo just echoes the command
echo "mock sudo: $@"
EOF
chmod +x "$MOCK_DIR/sudo"

# Override PATH so our mock is found first
export PATH="$MOCK_DIR:$PATH"

# Source the target script
. "$(dirname "${BASH_SOURCE[0]}")/install-filelight.sh"

# Run the function to test
if ! install_filelight; then
  echo "test_install-filelight.sh failed"
  exit 1
fi

echo "test_install-filelight.sh passed"
exit 0
