#!/bin/bash
set -euo pipefail

# Create a mock environment
MOCK_DIR=$(mktemp -d)

# Create a mock home directory
MOCK_HOME=$(mktemp -d)

# Trap both directories to avoid overwriting the trap
trap 'rm -rf "$MOCK_DIR" "$MOCK_HOME"' EXIT

# Set up the mock environment
export PATH="$MOCK_DIR:$PATH"
export HOME="$MOCK_HOME"

# Mock dependencies
cat << 'EOF' > "$MOCK_DIR/curl"
#!/bin/bash
# Mock curl by touching the output file
touch "$3"
EOF
chmod +x "$MOCK_DIR/curl"

# Mock bash to do nothing for the nvm install script, to avoid infinite loops if it calls itself
cat << 'EOF' > "$MOCK_DIR/bash"
#!/bin/bash
if [[ "$1" == "-n" ]]; then
  # Still allow syntax checking
  /bin/bash "$@"
elif [[ -n "$1" ]]; then
  # Do nothing for the script execution
  :
else
  # Pass through normal bash invocation
  /bin/bash "$@"
fi
EOF
chmod +x "$MOCK_DIR/bash"

# Also mock command to simulate gemini missing or present
cat << 'EOF' > "$MOCK_DIR/command"
#!/bin/bash
# Mock command to simulate gemini CLI not being installed initially
if [ "$1" == "-v" ] && [ "$2" == "gemini" ]; then
    exit 1
fi
/usr/bin/command "$@"
EOF
chmod +x "$MOCK_DIR/command"


# Mock nvm function instead of binary (since nvm is usually a shell function)
nvm() {
  if [ "$1" == "ls" ] && [ "$2" == "22" ]; then
    return 1 # Simulate Node 22 not installed
  elif [ "$1" == "install" ]; then
    echo "Mock nvm install $2"
  elif [ "$1" == "use" ]; then
    echo "Mock nvm use $2"
  elif [ "$1" == "alias" ]; then
    echo "Mock nvm alias $2 $3"
  fi
}
export -f nvm

export NPM_LOG="$MOCK_DIR/npm.log"
cat << 'EOF' > "$MOCK_DIR/npm"
#!/bin/bash
echo "$@" >> "$NPM_LOG"
EOF
chmod +x "$MOCK_DIR/npm"

# Source the script (this shouldn't execute anything because of the if block)
source ./install.sh

# Run the function
# Note: we don't mock the /usr/local/share/nvm files because they require root to create,
# but the script uses `[ -s ... ] && \. ...` so it won't fail if they don't exist.
install_dotfiles

if ! grep -q "install -g @google/gemini-cli" "$NPM_LOG"; then
  echo "FAIL: npm install for gemini-cli was not called." >&2
  exit 1
fi

echo "test_install.sh passed"
exit 0
