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

# Create a mock apt
cat << 'EOF' > "$MOCK_DIR/apt"
#!/bin/bash
echo "mock apt called with: $@" >&2
EOF
chmod +x "$MOCK_DIR/apt"

# Create a mock apt-get
cat << 'EOF' > "$MOCK_DIR/apt-get"
#!/bin/bash
echo "mock apt-get called with: $@" >&2
EOF
chmod +x "$MOCK_DIR/apt-get"

# Create a mock wget
cat << 'EOF' > "$MOCK_DIR/wget"
#!/bin/bash
echo "mock wget called with: $@" >&2
for arg in "$@"; do
  if [[ "$arg" == -O* ]]; then
    file="${arg#-O}"
    echo "mock gpg data" > "$file"
  fi
done
EOF
chmod +x "$MOCK_DIR/wget"

# Create a mock dpkg
cat << 'EOF' > "$MOCK_DIR/dpkg"
#!/bin/bash
echo "mock dpkg called with: $@" >&2
if [[ "$1" == "--print-architecture" ]]; then
  echo "amd64"
fi
EOF
chmod +x "$MOCK_DIR/dpkg"

# Prepend the mock directory to PATH
export PATH="$MOCK_DIR:$PATH"

# Source the script
source chromeos/install-gh-cli.sh

# Run the function
install_gh_cli

echo "test_install-gh-cli.sh passed"
exit 0
