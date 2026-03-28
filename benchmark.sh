#!/bin/bash
set -euo pipefail
# Generate a dummy file (1MB of random data should be enough to not be too slow but measure I/O)
dd if=/dev/urandom of=dummy.file bs=1M count=10 2>/dev/null

echo "Baseline (cat file | tee ...):"
time for i in {1..100}; do
    cat dummy.file | tee /dev/null > /dev/null
done

echo "Optimized (tee ... < file):"
time for i in {1..100}; do
    tee /dev/null < dummy.file > /dev/null
done

rm dummy.file
