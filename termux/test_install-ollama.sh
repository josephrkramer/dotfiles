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

install_ollama

echo "test_install-ollama.sh passed"
exit 0
