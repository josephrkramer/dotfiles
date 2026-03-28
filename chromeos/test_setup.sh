#!/bin/bash
set -euo pipefail

# Create a temporary directory for mock executables
MOCK_DIR=$(mktemp -d)
trap 'rm -rf "$MOCK_DIR"' EXIT

# Create a mock home directory to test NVM environment variables
export HOME="$MOCK_DIR/home"
mkdir -p "$HOME/.config/nvm"
touch "$HOME/.config/nvm/nvm.sh"
touch "$HOME/.config/nvm/bash_completion"

# Create mock scripts for the dependencies called in setup_chromeos
cat << 'EOF' > "$MOCK_DIR/install-btop.sh"
#!/bin/bash
echo "Mocked install-btop.sh"
EOF
chmod +x "$MOCK_DIR/install-btop.sh"

cat << 'EOF' > "$MOCK_DIR/set_git_config.sh"
#!/bin/bash
echo "Mocked set_git_config.sh"
EOF
chmod +x "$MOCK_DIR/set_git_config.sh"

cat << 'EOF' > "$MOCK_DIR/install-gh-cli.sh"
#!/bin/bash
echo "Mocked install-gh-cli.sh"
EOF
chmod +x "$MOCK_DIR/install-gh-cli.sh"

cat << 'EOF' > "$MOCK_DIR/install-vscode.sh"
#!/bin/bash
echo "Mocked install-vscode.sh"
EOF
chmod +x "$MOCK_DIR/install-vscode.sh"

cat << 'EOF' > "$MOCK_DIR/install-node.sh"
#!/bin/bash
echo "Mocked install-node.sh"
EOF
chmod +x "$MOCK_DIR/install-node.sh"

cat << 'EOF' > "$MOCK_DIR/install-gemini.sh"
#!/bin/bash
echo "Mocked install-gemini.sh"
EOF
chmod +x "$MOCK_DIR/install-gemini.sh"

cat << 'EOF' > "$MOCK_DIR/install-antigravity.sh"
#!/bin/bash
echo "Mocked install-antigravity.sh"
EOF
chmod +x "$MOCK_DIR/install-antigravity.sh"

# Mock 'gh' command
cat << 'EOF' > "$MOCK_DIR/gh"
#!/bin/bash
echo "Mocked gh $@"
EOF
chmod +x "$MOCK_DIR/gh"

# Override PATH to prioritize mocks
export PATH="$MOCK_DIR:$PATH"

# Determine the absolute directory of the script before pushing directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Go to the mock directory so relative paths in the script resolve to our mocks
pushd "$MOCK_DIR" > /dev/null

# Source the setup script using absolute path resolution
# The script is expected to be alongside this test file.
. "$SCRIPT_DIR/setup.sh"

echo "Testing headless=0 (default)..."
setup_chromeos

echo "Testing --headless..."
setup_chromeos --headless

popd > /dev/null

echo "test_setup.sh passed"
exit 0
