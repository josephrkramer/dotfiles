#!/bin/bash
export TEST_MOCK_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_MOCK_DIR"' EXIT

cat << 'INNER_EOF' > "$TEST_MOCK_DIR/sudo"
#!/bin/bash
echo "mock sudo \$*"
INNER_EOF
chmod +x "$TEST_MOCK_DIR/sudo"

cat << 'INNER_EOF' > "$TEST_MOCK_DIR/apt-get"
#!/bin/bash
echo "mock apt-get \$*"
INNER_EOF
chmod +x "$TEST_MOCK_DIR/apt-get"

cat << 'INNER_EOF' > "$TEST_MOCK_DIR/apt"
#!/bin/bash
echo "mock apt \$*"
INNER_EOF
chmod +x "$TEST_MOCK_DIR/apt"

cat << 'INNER_EOF' > "$TEST_MOCK_DIR/wget"
#!/bin/bash
echo "mock wget \$*"
INNER_EOF
chmod +x "$TEST_MOCK_DIR/wget"

cat << 'INNER_EOF' > "$TEST_MOCK_DIR/gpg"
#!/bin/bash
echo "mock gpg \$*"
INNER_EOF
chmod +x "$TEST_MOCK_DIR/gpg"

export PATH="$TEST_MOCK_DIR:$PATH"
. "$(pwd)/chromeos/install-vscode.sh"

install_vscode
