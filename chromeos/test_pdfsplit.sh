#!/bin/bash
set -euo pipefail

# Create a temporary directory for mock executables
MOCK_DIR=$(mktemp -d)
trap 'rm -rf "$MOCK_DIR"' EXIT

# Create a mock for qpdf
cat << 'EOF' > "$MOCK_DIR/qpdf"
#!/bin/bash
if [[ "$1" == "--show-npages" ]]; then
    echo "10"
    exit 0
fi
echo "Mocked qpdf $@"
EOF
chmod +x "$MOCK_DIR/qpdf"

# Override PATH to prioritize mocks
export PATH="$MOCK_DIR:$PATH"

# Determine the absolute directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the target script
. "$SCRIPT_DIR/pdfsplit.sh"

echo "Running tests for pdfsplit.sh..."

echo "Test 1: No arguments should fail and print usage"
OUTPUT=$(split_pdf 2>&1 || true)
if ! echo "$OUTPUT" | grep -q "Usage: ./pdfsplit.sh <filename.pdf> \[number_of_pieces\]"; then
    echo "FAIL: Expected usage error for no arguments" >&2
    echo "Got: $OUTPUT" >&2
    exit 1
fi

echo "Test 2: Non-existent file should fail and print usage"
OUTPUT=$(split_pdf "nonexistent_file.pdf" 2>&1 || true)
if ! echo "$OUTPUT" | grep -q "Usage: ./pdfsplit.sh <filename.pdf> \[number_of_pieces\]"; then
    echo "FAIL: Expected usage error for non-existent file" >&2
    echo "Got: $OUTPUT" >&2
    exit 1
fi

echo "Test 3: Valid file but invalid pieces should fail"
touch "$MOCK_DIR/dummy.pdf"
OUTPUT=$(split_pdf "$MOCK_DIR/dummy.pdf" "invalid" 2>&1 || true)
if ! echo "$OUTPUT" | grep -q "Error: Number of pieces must be a positive integer."; then
    echo "FAIL: Expected positive integer error for invalid pieces" >&2
    echo "Got: $OUTPUT" >&2
    exit 1
fi

echo "Test 4: Pieces > Total Pages should fail"
# Mock qpdf will return 10 pages. Try to split into 11 pieces.
OUTPUT=$(split_pdf "$MOCK_DIR/dummy.pdf" 11 2>&1 || true)
if ! echo "$OUTPUT" | grep -q "Error: Number of pieces exceeds number of pages."; then
    echo "FAIL: Expected error for pieces > pages" >&2
    echo "Got: $OUTPUT" >&2
    exit 1
fi

echo "Test 5: Valid file and valid pieces (happy path)"
OUTPUT=$(split_pdf "$MOCK_DIR/dummy.pdf" 2 2>&1 || true)
if ! echo "$OUTPUT" | grep -q "Successfully split '$MOCK_DIR/dummy.pdf' into 2 parts."; then
    echo "FAIL: Expected success message" >&2
    echo "Got: $OUTPUT" >&2
    exit 1
fi
if ! echo "$OUTPUT" | grep -q "Mocked qpdf --empty --pages $MOCK_DIR/dummy.pdf 1-5 -- $MOCK_DIR/dummy_part1.pdf"; then
    echo "FAIL: Expected qpdf call for part 1 not found" >&2
    echo "Got: $OUTPUT" >&2
    exit 1
fi
if ! echo "$OUTPUT" | grep -q "Mocked qpdf --empty --pages $MOCK_DIR/dummy.pdf 6-10 -- $MOCK_DIR/dummy_part2.pdf"; then
    echo "FAIL: Expected qpdf call for part 2 not found" >&2
    echo "Got: $OUTPUT" >&2
    exit 1
fi

echo "All tests passed for pdfsplit.sh!"
exit 0
