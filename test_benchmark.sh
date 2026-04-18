#!/bin/bash
set -euo pipefail

# Create a mock environment
MOCK_DIR=$(mktemp -d)
trap 'rm -rf "$MOCK_DIR"' EXIT

export PATH="$MOCK_DIR:$PATH"
export MOCK_LOG="$MOCK_DIR/mock.log"
hash -r

cat << 'INNER_EOF' > "$MOCK_DIR/dd"
#!/bin/bash
echo "dd $@" >> "$MOCK_LOG"
touch dummy.file
INNER_EOF
chmod +x "$MOCK_DIR/dd"

cat << 'INNER_EOF' > "$MOCK_DIR/cat"
#!/bin/bash
echo "cat $@" >> "$MOCK_LOG"
INNER_EOF
chmod +x "$MOCK_DIR/cat"

cat << 'INNER_EOF' > "$MOCK_DIR/tee"
#!/bin/bash
echo "tee $@" >> "$MOCK_LOG"
INNER_EOF
chmod +x "$MOCK_DIR/tee"

# We need to push into the mock directory to avoid creating dummy.file in our repo root
# Because dummy.file is created in current working dir
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pushd "$MOCK_DIR" > /dev/null

cat << 'RUN_TEST_EOF' > run_test.sh
#!/bin/bash
export PATH="$MOCK_DIR:$PATH"
export MOCK_LOG="$MOCK_LOG"
source "$SCRIPT_DIR/benchmark.sh"
run_benchmark
RUN_TEST_EOF
chmod +x run_test.sh

# Execute in a new shell to avoid function shadowing or path caching issues
MOCK_DIR="$MOCK_DIR" SCRIPT_DIR="$SCRIPT_DIR" MOCK_LOG="$MOCK_LOG" ./run_test.sh

# Verify dd
if ! grep -q "dd if=/dev/urandom of=dummy.file bs=1M count=10" "$MOCK_LOG"; then
    echo "FAIL: dd not called correctly"
    exit 1
fi

# Verify cat was called 100 times
if [[ $(grep -c "cat dummy.file" "$MOCK_LOG") -ne 100 ]]; then
    echo "FAIL: cat not called 100 times"
    exit 1
fi

# Verify tee was called 200 times
if [[ $(grep -c "tee /dev/null" "$MOCK_LOG") -ne 200 ]]; then
    echo "FAIL: tee not called 200 times"
    exit 1
fi

echo "test_benchmark.sh passed"
popd > /dev/null
exit 0
