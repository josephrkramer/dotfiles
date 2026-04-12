#!/bin/bash
set -euo pipefail

# Set up a mock directory
MOCK_DIR=$(mktemp -d)
trap 'rm -rf "$MOCK_DIR"' EXIT

# Create mocks for external commands
cat << 'EOF' > "$MOCK_DIR/sudo"
#!/bin/bash
echo "Mock sudo: $@"
EOF
chmod +x "$MOCK_DIR/sudo"

cat << 'EOF' > "$MOCK_DIR/apt"
#!/bin/bash
echo "Mock apt: $@"
EOF
chmod +x "$MOCK_DIR/apt"

cat << 'EOF' > "$MOCK_DIR/git"
#!/bin/bash
echo "Mock git: $@"
EOF
chmod +x "$MOCK_DIR/git"

cat << 'EOF' > "$MOCK_DIR/python3"
#!/bin/bash
if [[ "$1" == "-m" && "$2" == "venv" ]]; then
  echo "Mock python3 venv: $@"
  mkdir -p "$3/bin"
  touch "$3/bin/activate"
  chmod +x "$3/bin/activate"
else
  echo "Mock python3: $@"
fi
EOF
chmod +x "$MOCK_DIR/python3"

cat << 'EOF' > "$MOCK_DIR/pip3"
#!/bin/bash
echo "Mock pip3: $@"
EOF
chmod +x "$MOCK_DIR/pip3"

cat << 'EOF' > "$MOCK_DIR/pip"
#!/bin/bash
echo "Mock pip: $@"
EOF
chmod +x "$MOCK_DIR/pip"

# Override PATH to use mocks
export PATH="$MOCK_DIR:$PATH"

# Source the target script
source chromeos/install-tripo.sh

# Provide a mock TripoSR dir for 'cd TripoSR' to work
mkdir -p "$MOCK_DIR/TripoSR"
cd "$MOCK_DIR"
export HOME="$MOCK_DIR"

# Run the function
output=$(install_tripo)

# Verify that key commands were called. `set -e` will cause a failure if any are missing.
echo "$output" | grep -q "Mock sudo: apt update"
echo "$output" | grep -q "Mock sudo: apt install -y python3-pip python3-venv"
echo "$output" | grep -q "Mock git: clone https://github.com/VAST-AI-Research/TripoSR.git"
echo "$output" | grep -q "Mock python3 venv: -m venv .venv"
echo "$output" | grep -q "Mock pip3: install torch torchvision --index-url https://download.pytorch.org/whl/cpu"
echo "$output" | grep -q "Mock pip: install --upgrade setuptools"
echo "$output" | grep -q "Mock pip: install -r requirements.txt"

echo "test_install-tripo.sh passed"
exit 0