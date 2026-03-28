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
# Run the function to test and capture its output
output=$(install_filelight)

# Verify that the expected commands were run
if ! echo "$output" | grep -q "mock sudo: apt update"; then
  echo "FAIL: 'sudo apt update' was not called." >&2
  exit 1
fi

if ! echo "$output" | grep -q "mock sudo: apt install -y filelight"; then
  echo "FAIL: 'sudo apt install -y filelight' was not called." >&2
  exit 1
fi

echo "test_install-filelight.sh passed"
exit 0
