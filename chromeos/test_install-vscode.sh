#!/bin/bash
set -euo pipefail

# Test variables
export TEST_MOCK_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_MOCK_DIR"' EXIT

# Create mock for sudo
cat << 'EOF' > "$TEST_MOCK_DIR/sudo"
#!/bin/bash
echo "mock sudo $*"
EOF
chmod +x "$TEST_MOCK_DIR/sudo"

# Create mock for apt-get
cat << 'EOF' > "$TEST_MOCK_DIR/apt-get"
#!/bin/bash
echo "mock apt-get $*"
EOF
chmod +x "$TEST_MOCK_DIR/apt-get"

# Create mock for apt
cat << 'EOF' > "$TEST_MOCK_DIR/apt"
#!/bin/bash
echo "mock apt $*"
EOF
chmod +x "$TEST_MOCK_DIR/apt"

# Create mock for wget
cat << 'EOF' > "$TEST_MOCK_DIR/wget"
#!/bin/bash
echo "mock wget $*"
EOF
chmod +x "$TEST_MOCK_DIR/wget"

# Create mock for gpg
cat << 'EOF' > "$TEST_MOCK_DIR/gpg"
#!/bin/bash
echo "mock gpg $*"
EOF
chmod +x "$TEST_MOCK_DIR/gpg"

# Set PATH to intercept commands
export PATH="$TEST_MOCK_DIR:$PATH"

# Source the target script
. "$(dirname "${BASH_SOURCE[0]}")/install-vscode.sh"

# Run tests
echo "Testing install_vscode..."
if ! output=$(install_vscode 2>&1); then
  echo "❌ install_vscode failed with a non-zero exit code."
  echo "Output:"
  echo "$output"
  exit 1
fi

# Example check for a key command. Consider adding more checks for coverage.
if ! echo "$output" | grep -q "mock apt-get update"; then
  echo "❌ Test failed: 'apt-get update' was not called."
  echo "Output:"
  echo "$output"
  exit 1
fi

echo "✅ chromeos/test_install-vscode.sh passed"
exit 0
