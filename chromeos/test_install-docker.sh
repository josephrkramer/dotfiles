#!/bin/bash
set -euo pipefail

# Create mock directory
MOCK_DIR=$(mktemp -d)
trap 'rm -rf "$MOCK_DIR"' EXIT
export PATH="$MOCK_DIR:$PATH"

# Create mock for sudo that logs calls
SUDO_LOG="$MOCK_DIR/sudo.log"
cat > "$MOCK_DIR/sudo" << 'MOCK'
#!/bin/bash
echo "$@" >> "$SUDO_LOG"
MOCK
chmod +x "$MOCK_DIR/sudo"

# Create mock os-release to make test hermetic
MOCK_OS_RELEASE="$MOCK_DIR/os-release"
cat > "$MOCK_OS_RELEASE" <<EOF
ID=debian
VERSION_CODENAME=bullseye
EOF

# Source a modified version of the script that uses the mock os-release
MOCKED_INSTALL_SCRIPT="$MOCK_DIR/install-docker.sh"
sed "s|\. /etc/os-release|. $MOCK_OS_RELEASE|g" chromeos/install-docker.sh > "$MOCKED_INSTALL_SCRIPT"
source "$MOCKED_INSTALL_SCRIPT"

# Call the function
install_docker

echo "test_install-docker.sh passed"
