#!/bin/bash
set -euo pipefail

echo "Running benchmark test..."

# Ensure we start clean
rm -f dummy.file

# Run the benchmark script
./benchmark.sh >/dev/null 2>&1

# Check if dummy.file was created
if [[ -e dummy.file ]]; then
    echo "FAIL: dummy.file was created!"
    exit 1
fi

echo "PASS: benchmark.sh executed successfully without creating predictable temporary files."
