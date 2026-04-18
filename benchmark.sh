#!/bin/bash
set -euo pipefail
# Generate a dummy file (1MB of random data should be enough to not be too slow but measure I/O)
TMP_FILE=$(mktemp "${TMPDIR:-/tmp}/benchmark.XXXXXXXXXX")
trap 'rm -f "$TMP_FILE"' EXIT

dd if=/dev/urandom of="$TMP_FILE" bs=1024k count=10 2>/dev/null

echo "Baseline (cat file | tee ...):"
time for i in {1..100}; do
    cat "$TMP_FILE" | tee /dev/null > /dev/null
done

echo "Optimized (tee ... < file):"
time for i in {1..100}; do
    tee /dev/null < "$TMP_FILE" > /dev/null
done
