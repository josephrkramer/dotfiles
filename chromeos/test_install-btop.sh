#!/bin/bash
set -euo pipefail

# Set up mock environment
MOCK_DIR=$(mktemp -d)
trap 'rm -rf "$MOCK_DIR"' EXIT

export PATH="$MOCK_DIR:$PATH"

# Create mock for sudo
cat << 'EOF' > "$MOCK_DIR/sudo"
#!/bin/bash
echo "MOCK SUDO: $@" >&2
if [[ "${MOCK_SUDO_FAIL:-0}" == "1" ]]; then
    exit 1
fi
exit 0
EOF
chmod +x "$MOCK_DIR/sudo"

# Source the script
. "$(dirname "${BASH_SOURCE[0]}")/install-btop.sh"

echo "Running tests for chromeos/install-btop.sh..."

# Test 1: Happy path
echo "Test 1: Happy path"
export MOCK_SUDO_FAIL=0
if install_btop; then
    echo "  Passed: install_btop succeeded as expected."
else
    echo "  Failed: install_btop should have succeeded."
    exit 1
fi

# Test 2: Error path (sudo fails)
echo "Test 2: Error path"
export MOCK_SUDO_FAIL=1
if ! install_btop; then
    echo "  Passed: install_btop failed as expected."
else
    echo "  Failed: install_btop should have failed."
    exit 1
fi

echo "All tests passed for chromeos/install-btop.sh"
exit 0
