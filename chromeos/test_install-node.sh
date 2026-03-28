#!/bin/bash
set -euo pipefail

# Source the script we want to test
source chromeos/install-node.sh

# Setup mock environment
MOCK_DIR=$(mktemp -d)
trap 'rm -rf "$MOCK_DIR"' EXIT
export PATH="$MOCK_DIR:$PATH"
export HOME="$MOCK_DIR" # Isolate HOME so NVM_DIR is inside the mock directory

# Create a place to record calls
CALL_LOG="$MOCK_DIR/calls.log"
touch "$CALL_LOG"

# Helper function to mock commands
mock_command() {
  local cmd_name="$1"
  local mock_logic="${2:-echo \$@ >> $CALL_LOG}"

  cat <<EOF > "$MOCK_DIR/$cmd_name"
#!/bin/bash
$mock_logic
EOF
  chmod +x "$MOCK_DIR/$cmd_name"
}

# --- Test 1: NVM is not installed ---
test_nvm_not_installed() {
  echo "Running test: test_nvm_not_installed"
  rm -f "$CALL_LOG" && touch "$CALL_LOG"
  rm -rf "$HOME/.config/nvm"

  mock_command curl "echo 'curl' >> $CALL_LOG"
  # We actually want bash to NOT execute stdin, so we mock bash too
  # but ONLY for the script's curl | bash part.
  # However, replacing bash in PATH can be tricky for the test runner.
  # Since curl is mocked, curl's output is 'curl\n', piped to bash.
  # So we mock curl to output nothing or just a safe command.
  mock_command curl "echo 'echo mocked_curl_download'"

  # For nvm command, we need a mock function because it is sourced, not an executable in PATH
  # But in the script, nvm.sh is sourced and it provides nvm function.
  # We need to create a fake nvm.sh
  mkdir -p "$HOME/.config/nvm"
  cat <<EOF > "$HOME/.config/nvm/nvm.sh"
nvm() {
  echo "nvm \$@" >> $CALL_LOG
  # Simulate 'nvm ls 22' failure so it goes to installation
  if [[ "\$1" == "ls" && "\$2" == "22" ]]; then
    return 1
  fi
}
EOF
  # Remove NVM_DIR so it triggers installation
  rm -rf "$HOME/.config/nvm"

  # To fake nvm.sh appearing after curl | bash, we can make the mocked bash script create it
  mock_command curl "echo 'mkdir -p $HOME/.config/nvm && echo \"nvm() { echo \\\"nvm \\\$@\\\" >> $CALL_LOG; if [[ \\\"\\\$1\\\" == \\\"ls\\\" && \\\"\\\$2\\\" == \\\"22\\\" ]]; then return 1; fi; }\" > $HOME/.config/nvm/nvm.sh'"

  # Let install_node run
  install_node > /dev/null

  # Assertions
  # Since nvm dir did not exist, curl should have been run (the generated script created nvm.sh)
  if [ ! -f "$HOME/.config/nvm/nvm.sh" ]; then
    echo "Error: curl was not called to install nvm"
    exit 1
  fi

  if ! grep -q "nvm install 22" "$CALL_LOG"; then
    echo "Error: 'nvm install 22' was not called"
    exit 1
  fi
}

# --- Test 2: NVM is installed but Node.js v22 is not ---
test_nvm_installed_node_not_installed() {
  echo "Running test: test_nvm_installed_node_not_installed"
  rm -f "$CALL_LOG" && touch "$CALL_LOG"

  mkdir -p "$HOME/.config/nvm"
  cat <<EOF > "$HOME/.config/nvm/nvm.sh"
nvm() {
  echo "nvm \$@" >> $CALL_LOG
  if [[ "\$1" == "ls" && "\$2" == "22" ]]; then
    return 1
  fi
}
EOF

  # Mock curl to catch if it is wrongly called
  mock_command curl "echo 'curl called unexpectedly' >> $CALL_LOG"

  install_node > /dev/null

  if grep -q "curl called unexpectedly" "$CALL_LOG"; then
    echo "Error: curl should not be called if NVM_DIR exists"
    exit 1
  fi

  if ! grep -q "nvm install 22" "$CALL_LOG"; then
    echo "Error: 'nvm install 22' was not called"
    exit 1
  fi
}

# --- Test 3: NVM is installed AND Node.js v22 is installed ---
test_nvm_installed_node_installed() {
  echo "Running test: test_nvm_installed_node_installed"
  rm -f "$CALL_LOG" && touch "$CALL_LOG"

  mkdir -p "$HOME/.config/nvm"
  cat <<EOF > "$HOME/.config/nvm/nvm.sh"
nvm() {
  echo "nvm \$@" >> $CALL_LOG
  if [[ "\$1" == "ls" && "\$2" == "22" ]]; then
    return 0 # simulate success
  fi
}
EOF

  mock_command curl "echo 'curl called unexpectedly' >> $CALL_LOG"

  install_node > /dev/null

  if grep -q "nvm install 22" "$CALL_LOG"; then
    echo "Error: 'nvm install 22' should not be called if Node.js v22 is already installed"
    exit 1
  fi
}

# Run tests
test_nvm_not_installed
test_nvm_installed_node_not_installed
test_nvm_installed_node_installed

echo "chromeos/test_install-node.sh passed"
exit 0
