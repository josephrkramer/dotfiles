#!/bin/bash
set -euo pipefail


split_pdf() {
    # 1. Check if qpdf is installed
    if ! command -v qpdf &> /dev/null; then
        echo "Error: qpdf is not installed. Install it with: sudo apt install qpdf"
        return 1
    fi

    # 2. Check for required input
    local FILE="${1:-}"
    local PIECES="${2:-2}" # Defaults to 2 if second argument is missing

    if [[ -z "$FILE" || ! -f "$FILE" ]]; then
        echo "Usage: ./pdfsplit.sh <filename.pdf> [number_of_pieces]"
        return 1
    fi

    if ! [[ "$PIECES" =~ ^[0-9]+$ ]] || [ "$PIECES" -le 0 ]; then
        echo "Error: Number of pieces must be a positive integer."
        return 1
    fi

    # 3. Get total page count
    local TOTAL_PAGES
    TOTAL_PAGES=$(qpdf --show-npages "$FILE")

    # 4. Calculate pages per piece (integer division)
    local PAGES_PER_PIECE=$((TOTAL_PAGES / PIECES))

    if [ "$PAGES_PER_PIECE" -eq 0 ]; then
        echo "Error: Number of pieces exceeds number of pages."
        return 1
    fi

    echo "Total pages: $TOTAL_PAGES"
    echo "Splitting into $PIECES pieces (approx $PAGES_PER_PIECE pages each)..."

    # 5. Loop and extract
    local START END OUTPUT_NAME i
    for ((i=1; i<=PIECES; i++)); do
        START=$(( (i - 1) * PAGES_PER_PIECE + 1 ))

        # If it's the last piece, capture all remaining pages
        if [ "$i" -eq "$PIECES" ]; then
            END=$TOTAL_PAGES
        else
            END=$(( i * PAGES_PER_PIECE ))
        fi

        OUTPUT_NAME="${FILE%.[Pp][Dd][Ff]}_part${i}.pdf"

        echo "Creating $OUTPUT_NAME (Pages $START-$END)..."
        qpdf --empty --pages "$FILE" "$START-$END" -- "$OUTPUT_NAME"
    done

    echo "Successfully split '$FILE' into $PIECES parts."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    split_pdf "$@"
fi
