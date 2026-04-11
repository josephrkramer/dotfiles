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

# Helper function to create mock scripts
create_mock() {
  local script_name="$1"
  cat << EOF > "$MOCK_DIR/$script_name"
#!/bin/bash
echo "Mocked $script_name"
EOF
  chmod +x "$MOCK_DIR/$script_name"
}

# Create mock scripts for the dependencies called in setup_chromeos
create_mock "install-btop.sh"
create_mock "set_git_config.sh"
create_mock "install-gh-cli.sh"
create_mock "install-vscode.sh"
create_mock "install-node.sh"
create_mock "install-gemini.sh"
create_mock "install-antigravity.sh"
create_mock "install-nvidia-sync.sh"

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
output=$(setup_chromeos)
echo "$output" | grep -q "Mocked install-vscode.sh"
echo "$output" | grep -q "Mocked install-antigravity.sh"
echo "$output" | grep -q "Mocked install-nvidia-sync.sh"

echo "Testing --headless..."
output=$(setup_chromeos --headless)
if echo "$output" | grep -q "Mocked install-vscode.sh"; then
  echo "FAIL: install-vscode.sh was called in headless mode" >&2
  exit 1
fi
if echo "$output" | grep -q "Mocked install-antigravity.sh"; then
  echo "FAIL: install-antigravity.sh was called in headless mode" >&2
  exit 1
fi
if echo "$output" | grep -q "Mocked install-nvidia-sync.sh"; then
  echo "FAIL: install-nvidia-sync.sh was called in headless mode" >&2
  exit 1
fi

popd > /dev/null

echo "test_setup.sh passed"
exit 0
