#!/bin/bash
# Get the next ADR number
# Usage: next-adr.sh /path/to/adrs

ADR_DIR="$1"

if [ -z "$ADR_DIR" ]; then
    echo "Usage: next-adr.sh /path/to/adrs" >&2
    exit 1
fi

if [ ! -d "$ADR_DIR" ]; then
    echo "001"
    exit 0
fi

# Find the highest numbered ADR
HIGHEST=$(ls -1 "$ADR_DIR" 2>/dev/null | grep -E '^[0-9]{3}-' | sed 's/^\([0-9]\{3\}\).*/\1/' | sort -n | tail -1)

if [ -z "$HIGHEST" ]; then
    echo "001"
else
    # Remove leading zeros, increment, then pad back
    NEXT=$((10#$HIGHEST + 1))
    printf "%03d\n" "$NEXT"
fi
