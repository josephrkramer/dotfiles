#!/bin/bash
set -euo pipefail

# Create a mock directory for commands
MOCK_DIR=$(mktemp -d)
trap 'rm -rf "$MOCK_DIR"' EXIT

# Create mock for sudo
cat << 'EOF' > "$MOCK_DIR/sudo"
#!/bin/bash
echo "sudo $*"
# Simulate successful execution of the mocked command
exit 0
EOF
chmod +x "$MOCK_DIR/sudo"

# Create mock for curl
cat << 'EOF' > "$MOCK_DIR/curl"
#!/bin/bash
echo "curl $*"
# Simulate output for curl so gpg/tee don't fail if they need input (though we mock them too)
echo "mocked curl output"
exit 0
EOF
chmod +x "$MOCK_DIR/curl"

# Create mock for apt
cat << 'EOF' > "$MOCK_DIR/apt"
#!/bin/bash
echo "apt $*"
exit 0
EOF
chmod +x "$MOCK_DIR/apt"

# Override PATH to put MOCK_DIR first
export PATH="$MOCK_DIR:$PATH"

# Source the script
. "$(dirname "${BASH_SOURCE[0]}")/install-antigravity.sh"

# Run the function
if ! install_antigravity; then
  echo "test_install-antigravity.sh failed"
  exit 1
fi

echo "test_install-antigravity.sh passed"
exit 0
