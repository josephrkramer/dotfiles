#!/bin/bash
set -euo pipefail

# Create a mock directory for our executables
MOCK_DIR=$(mktemp -d)
trap 'rm -rf "$MOCK_DIR"' EXIT

# Create a mock sudo
cat << 'EOF' > "$MOCK_DIR/sudo"
#!/bin/bash
# Note: we use >&2 to ensure output is visible since sudo tee is piped to /dev/null
echo "mock sudo called with: $@" >&2
# Execute the underlying command to trigger the other mocks
"$@"
EOF
chmod +x "$MOCK_DIR/sudo"

# Create a mock apt-get
cat << 'EOF' > "$MOCK_DIR/apt-get"
#!/bin/bash
echo "mock apt-get called with: $@"
EOF
chmod +x "$MOCK_DIR/apt-get"

# Create a mock apt
cat << 'EOF' > "$MOCK_DIR/apt"
#!/bin/bash
echo "mock apt called with: $@"
EOF
chmod +x "$MOCK_DIR/apt"

# Create a mock wget
cat << 'EOF' > "$MOCK_DIR/wget"
#!/bin/bash
echo "mock wget called with: $@"
# Output mock ascii to stdout for gpg pipe
echo "mock ascii payload"
EOF
chmod +x "$MOCK_DIR/wget"

# Create a mock gpg
cat << 'EOF' > "$MOCK_DIR/gpg"
#!/bin/bash
echo "mock gpg called with: $@" >&2
# Write mock binary data to stdout
echo "mock gpg payload"
EOF
chmod +x "$MOCK_DIR/gpg"

# Create a mock install
cat << 'EOF' > "$MOCK_DIR/install"
#!/bin/bash
echo "mock install called with: $@"
EOF
chmod +x "$MOCK_DIR/install"

# Create a mock tee
cat << 'EOF' > "$MOCK_DIR/tee"
#!/bin/bash
echo "mock tee called with: $@"
EOF
chmod +x "$MOCK_DIR/tee"


# Create a mock rm
cat << 'EOF' > "$MOCK_DIR/rm"
#!/bin/bash
echo "mock rm called with: $@"
EOF
chmod +x "$MOCK_DIR/rm"

# Prepend the mock directory to PATH
export PATH="$MOCK_DIR:$PATH"

# Resolve absolute path before pushing into MOCK_DIR
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Push into MOCK_DIR to avoid leaving generated artifacts in tree if not mocked perfectly
pushd "$MOCK_DIR" > /dev/null

# Source the script (this won't execute the main logic because we check BASH_SOURCE)
source "$SCRIPT_DIR/install-vscode.sh"

# Run the function
install_vscode

popd > /dev/null

echo "test_install-vscode.sh passed"
exit 0
