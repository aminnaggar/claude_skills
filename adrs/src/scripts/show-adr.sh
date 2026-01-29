#!/bin/bash
# Show full ADR content
# Usage: show-adr.sh /path/to/adrs <id>
#
# Examples:
#   show-adr.sh ./adrs 003
#   show-adr.sh ./adrs ADR-003

ADR_DIR="$1"
ID="$2"

if [ -z "$ADR_DIR" ] || [ -z "$ID" ]; then
    echo "Usage: show-adr.sh /path/to/adrs <id>" >&2
    exit 1
fi

if [ ! -d "$ADR_DIR" ]; then
    echo "Error: Directory not found: $ADR_DIR" >&2
    exit 1
fi

# Normalize ID - extract number if given as ADR-XXX
ID_NUM=$(echo "$ID" | sed 's/^ADR-//' | sed 's/^0*//')
ID_PADDED=$(printf "%03d" "$ID_NUM")

# Find the file
FILE=$(ls -1 "$ADR_DIR"/${ID_PADDED}-*.md 2>/dev/null | head -1)

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
    echo "Error: ADR not found: $ID" >&2
    exit 1
fi

cat "$FILE"
