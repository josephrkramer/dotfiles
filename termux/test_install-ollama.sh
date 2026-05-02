#!/bin/bash
set -euo pipefail

MOCK_DIR="$(mktemp -d)"
trap 'rm -rf "$MOCK_DIR"' EXIT

cat << 'EOF' > "$MOCK_DIR/pkg"
#!/bin/bash
echo "Mock pkg called with args: $*" >&2
EOF
chmod +x "$MOCK_DIR/pkg"

export PATH="$MOCK_DIR:$PATH"

. "$(dirname "${BASH_SOURCE[0]}")/install-ollama.sh"

OUTPUT="$(install_ollama 2>&1)"
EXPECTED="Mock pkg called with args: install -y ollama"

if ! echo "$OUTPUT" | grep -q "$EXPECTED"; then
  echo "Test failed: Unexpected output from install_ollama." >&2
  echo "Expected: '$EXPECTED'" >&2
  echo "Actual:   '$OUTPUT'" >&2
  exit 1
fi

echo "test_install-ollama.sh passed"
exit 0
