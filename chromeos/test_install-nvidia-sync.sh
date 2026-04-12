#!/bin/bash
set -euo pipefail

# Create a mock directory for our executables
MOCK_DIR=$(mktemp -d)
trap 'rm -rf "$MOCK_DIR"' EXIT

# Create a mock sudo
cat << 'EOF' > "$MOCK_DIR/sudo"
#!/bin/bash
echo "mock sudo called with: $@" >&2
EOF
chmod +x "$MOCK_DIR/sudo"

# Create a mock curl
cat << 'EOF' > "$MOCK_DIR/curl"
#!/bin/bash
echo "mock curl called with: $@"
EOF
chmod +x "$MOCK_DIR/curl"

# Create a mock apt
cat << 'EOF' > "$MOCK_DIR/apt"
#!/bin/bash
echo "mock apt called with: $@"
EOF
chmod +x "$MOCK_DIR/apt"

# Create a mock tee
cat << 'EOF' > "$MOCK_DIR/tee"
#!/bin/bash
echo "mock tee called with: $@"
EOF
chmod +x "$MOCK_DIR/tee"

# Prepend the mock directory to PATH
export PATH="$MOCK_DIR:$PATH"

# Source the script (this won't execute the main logic because we check BASH_SOURCE)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/install-nvidia-sync.sh"

# Run the function
install_nvidia_sync

echo "test_install-nvidia-sync.sh passed"
exit 0
