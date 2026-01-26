#!/bin/bash
# Find the next ticket number or sub-ticket letter
# Usage: next-ticket.sh /path/to/tickets [parent_number]
#
# Examples:
#   next-ticket.sh ./tickets           # Returns next main ticket number (e.g., "008")
#   next-ticket.sh ./tickets 005       # Returns next sub-ticket (e.g., "005c")

TICKETS_DIR="$1"
PARENT="$2"

if [ -z "$TICKETS_DIR" ]; then
    echo "Usage: next-ticket.sh /path/to/tickets [parent_number]" >&2
    exit 1
fi

if [ ! -d "$TICKETS_DIR" ]; then
    echo "Error: Directory not found: $TICKETS_DIR" >&2
    exit 1
fi

if [ -z "$PARENT" ]; then
    # Find next main ticket number
    # List directories, extract numeric prefixes (excluding sub-tickets with letters)
    HIGHEST=$(ls -1 "$TICKETS_DIR" 2>/dev/null | \
        grep -E '^[0-9]{3}_' | \
        grep -vE '^[0-9]{3}[a-z]_' | \
        sed 's/_.*//' | \
        sort -n | \
        tail -1)

    if [ -z "$HIGHEST" ]; then
        # No tickets yet, start at 001
        printf "%03d\n" 1
    else
        # Remove leading zeros for arithmetic, then add 1
        NEXT=$((10#$HIGHEST + 1))
        printf "%03d\n" $NEXT
    fi
else
    # Find next sub-ticket letter for given parent
    # List directories matching parent prefix with a letter suffix
    HIGHEST_LETTER=$(ls -1 "$TICKETS_DIR" 2>/dev/null | \
        grep -E "^${PARENT}[a-z]_" | \
        sed "s/^${PARENT}//" | \
        sed 's/_.*//' | \
        sort | \
        tail -1)

    if [ -z "$HIGHEST_LETTER" ]; then
        # No sub-tickets yet, start at 'a'
        echo "${PARENT}a"
    else
        # Get next letter
        NEXT_LETTER=$(echo "$HIGHEST_LETTER" | tr 'a-y' 'b-z')
        if [ "$NEXT_LETTER" = "$HIGHEST_LETTER" ]; then
            # We hit 'z', this is an edge case
            echo "Error: Exceeded maximum sub-tickets (z)" >&2
            exit 1
        fi
        echo "${PARENT}${NEXT_LETTER}"
    fi
fi
