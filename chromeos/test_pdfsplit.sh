#!/bin/bash
set -euo pipefail

# Set up mock environment
MOCK_DIR=$(mktemp -d)
trap 'rm -rf "$MOCK_DIR"' EXIT

export PATH="$MOCK_DIR:$PATH"
QPDF_CALLS_LOG="$MOCK_DIR/qpdf_calls.log"
export QPDF_CALLS_LOG

# Create mock for qpdf
cat << 'EOF' > "$MOCK_DIR/qpdf"
#!/bin/bash
echo "$@" >> "$QPDF_CALLS_LOG"
echo "MOCK QPDF: $@" >&2
if [[ "${MOCK_QPDF_FAIL:-0}" == "1" ]]; then
    exit 1
fi
if [[ "$1" == "--show-npages" ]]; then
    echo "${MOCK_QPDF_PAGES:-10}"
    exit 0
fi
exit 0
EOF
chmod +x "$MOCK_DIR/qpdf"

# Source the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/pdfsplit.sh"

echo "Running tests for chromeos/pdfsplit.sh..."

pushd "$MOCK_DIR" >/dev/null

# Test 1: qpdf missing
echo "Test 1: qpdf missing error"
# Hide qpdf
mv "$MOCK_DIR/qpdf" "$MOCK_DIR/qpdf.hidden"
if ! OUTPUT=$(split_pdf "test.pdf" 2>&1); then
    echo "  Passed: split_pdf failed as expected."
else
    echo "  Failed: split_pdf should have failed without qpdf."
    exit 1
fi
if echo "$OUTPUT" | grep -q "qpdf is not installed"; then
    echo "  Passed: Expected error message found."
else
    echo "  Failed: Did not find expected error message."
    exit 1
fi
# Restore qpdf
mv "$MOCK_DIR/qpdf.hidden" "$MOCK_DIR/qpdf"

# Create a dummy PDF file for testing
touch "test.pdf"

# Test 2: Missing filename argument
echo "Test 2: Missing filename argument"
if ! OUTPUT=$(split_pdf 2>&1); then
    echo "  Passed: split_pdf failed as expected."
else
    echo "  Failed: split_pdf should have failed with no arguments."
    exit 1
fi
if echo "$OUTPUT" | grep -q "Usage: ./pdfsplit.sh"; then
    echo "  Passed: Expected usage message found."
else
    echo "  Failed: Did not find expected usage message."
    exit 1
fi

# Test 3: Invalid PIECES argument
echo "Test 3: Invalid PIECES argument"
if ! OUTPUT=$(split_pdf "test.pdf" "abc" 2>&1); then
    echo "  Passed: split_pdf failed as expected."
else
    echo "  Failed: split_pdf should have failed with invalid PIECES."
    exit 1
fi
if echo "$OUTPUT" | grep -q "Number of pieces must be a positive integer"; then
    echo "  Passed: Expected error message found."
else
    echo "  Failed: Did not find expected error message."
    exit 1
fi

if ! OUTPUT=$(split_pdf "test.pdf" "0" 2>&1); then
    echo "  Passed: split_pdf failed as expected (0 pieces)."
else
    echo "  Failed: split_pdf should have failed with 0 pieces."
    exit 1
fi

# Test 4: PIECES exceeding total number of pages
echo "Test 4: PIECES exceeding total pages"
export MOCK_QPDF_PAGES=5
if ! OUTPUT=$(split_pdf "test.pdf" "10" 2>&1); then
    echo "  Passed: split_pdf failed as expected."
else
    echo "  Failed: split_pdf should have failed when pieces > pages."
    exit 1
fi
if echo "$OUTPUT" | grep -q "Number of pieces exceeds number of pages"; then
    echo "  Passed: Expected error message found."
else
    echo "  Failed: Did not find expected error message."
    exit 1
fi

# Test 5: Happy path (default PIECES=2)
echo "Test 5: Happy path (default PIECES=2, 10 pages)"
export MOCK_QPDF_PAGES=10
rm -f "$QPDF_CALLS_LOG"
if split_pdf "test.pdf"; then
    echo "  Passed: split_pdf succeeded."
else
    echo "  Failed: split_pdf should have succeeded."
    exit 1
fi

if grep -q "\-\-empty \-\-pages test.pdf 1-5 \-\- test_part1.pdf" "$QPDF_CALLS_LOG" && \
   grep -q "\-\-empty \-\-pages test.pdf 6-10 \-\- test_part2.pdf" "$QPDF_CALLS_LOG"; then
    echo "  Passed: Correct qpdf arguments passed for part 1 and 2."
else
    echo "  Failed: Incorrect qpdf arguments logged."
    cat "$QPDF_CALLS_LOG"
    exit 1
fi

# Test 6: Happy path (PIECES=3, 10 pages)
echo "Test 6: Happy path (PIECES=3, 10 pages)"
export MOCK_QPDF_PAGES=10
rm -f "$QPDF_CALLS_LOG"
if split_pdf "test.pdf" 3; then
    echo "  Passed: split_pdf succeeded."
else
    echo "  Failed: split_pdf should have succeeded."
    exit 1
fi

if grep -q "\-\-empty \-\-pages test.pdf 1-3 \-\- test_part1.pdf" "$QPDF_CALLS_LOG" && \
   grep -q "\-\-empty \-\-pages test.pdf 4-6 \-\- test_part2.pdf" "$QPDF_CALLS_LOG" && \
   grep -q "\-\-empty \-\-pages test.pdf 7-10 \-\- test_part3.pdf" "$QPDF_CALLS_LOG"; then
    echo "  Passed: Correct qpdf arguments passed for part 1, 2, and 3."
else
    echo "  Failed: Incorrect qpdf arguments logged."
    cat "$QPDF_CALLS_LOG"
    exit 1
fi

popd >/dev/null

echo "All tests passed for chromeos/pdfsplit.sh"
exit 0
