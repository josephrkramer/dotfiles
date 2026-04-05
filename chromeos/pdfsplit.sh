#!/bin/bash
set -euo pipefail


# 1. Check if qpdf is installed
if ! command -v qpdf &> /dev/null; then
    echo "Error: qpdf is not installed. Install it with: sudo apt install qpdf"
    exit 1
fi

# 2. Check for required input
FILE=$1
PIECES=${2:-2} # Defaults to 2 if second argument is missing

if [[ -z "$FILE" || ! -f "$FILE" ]]; then
    echo "Usage: ./pdfsplit.sh <filename.pdf> [number_of_pieces]"
    exit 1
fi

if ! [[ "$PIECES" =~ ^[0-9]+$ ]] || [ "$PIECES" -le 0 ]; then
    echo "Error: Number of pieces must be a positive integer."
    exit 1
fi

# 3. Get total page count
TOTAL_PAGES=$(qpdf --show-npages "$FILE")

# 4. Calculate pages per piece (integer division)
PAGES_PER_PIECE=$((TOTAL_PAGES / PIECES))

if [ "$PAGES_PER_PIECE" -eq 0 ]; then
    echo "Error: Number of pieces exceeds number of pages."
    exit 1
fi

echo "Total pages: $TOTAL_PAGES"
echo "Splitting into $PIECES pieces (approx $PAGES_PER_PIECE pages each)..."

# 5. Loop and extract
for i in $(seq 1 "$PIECES"); do
    START=$(( (i - 1) * PAGES_PER_PIECE + 1 ))
    
    # If it's the last piece, capture all remaining pages
    if [ "$i" -eq "$PIECES" ]; then
        END=$TOTAL_PAGES
    else
        END=$(( i * PAGES_PER_PIECE ))
    fi
    
    OUTPUT_NAME="${FILE%.pdf}_part${i}.pdf"
    
    echo "Creating $OUTPUT_NAME (Pages $START-$END)..."
    qpdf --empty --pages "$FILE" "$START-$END" -- "$OUTPUT_NAME"
done

echo "Successfully split '$FILE' into $PIECES parts."
