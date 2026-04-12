#!/bin/bash
set -euo pipefail
# Create a mock environment
MOCK_DIR=$(mktemp -d)
export PATH="$MOCK_DIR:$PATH"
export NVM_DIR="$MOCK_DIR/.nvm"
mkdir -p "$NVM_DIR"

trap 'rm -rf "$MOCK_DIR"' EXIT

# Mock npm to prevent actual installation during testing
cat << 'EOF' > "$MOCK_DIR/npm"
#!/bin/bash
echo "Mock npm called with args: $@"
EOF
chmod +x "$MOCK_DIR/npm"

# Mock command to simulate opencode not being installed
# We override the builtin command so we can fake the check
# However, `command -v opencode` is used in the script.
# `command` is a shell builtin. We can create a function to intercept it.
# Actually, it's better to just ensure opencode is not in the mock path.
# We don't need to mock `command`. The script will use `command -v opencode`.
# Since `opencode` is not in the mock path, it will fail, which is what we want for the install path test.


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/install-opencode.sh"

# Run the function
if ! install_opencode; then
    echo "test_install-opencode.sh failed"
    exit 1
fi

echo "test_install-opencode.sh passed"
exit 0
