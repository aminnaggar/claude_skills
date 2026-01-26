#!/bin/bash
# Set ticket status with proper field management
# Usage: set-status.sh /path/to/tickets <ticket_id> <status>
#
# Examples:
#   set-status.sh ./tickets 007 done      # Mark ticket 007 as done
#   set-status.sh ./tickets 005a current  # Mark sub-ticket 005a as current
#   set-status.sh ./tickets 003 todo      # Reopen ticket 003

TICKETS_DIR="$1"
TICKET_ID="$2"
NEW_STATUS="$3"

if [ -z "$TICKETS_DIR" ] || [ -z "$TICKET_ID" ] || [ -z "$NEW_STATUS" ]; then
    echo "Usage: set-status.sh /path/to/tickets <ticket_id> <status>" >&2
    echo "" >&2
    echo "Valid statuses: draft, todo, current, done" >&2
    exit 1
fi

# Validate status
if [[ ! "$NEW_STATUS" =~ ^(draft|todo|current|done)$ ]]; then
    echo "Error: Invalid status '$NEW_STATUS'" >&2
    echo "Valid statuses: draft, todo, current, done" >&2
    exit 1
fi

if [ ! -d "$TICKETS_DIR" ]; then
    echo "Error: Directory not found: $TICKETS_DIR" >&2
    exit 1
fi

# Find ticket directory (matches NNN_slug or NNNx_slug patterns)
TICKET_DIR=$(ls -1 "$TICKETS_DIR" | grep -E "^${TICKET_ID}_" | head -1)

if [ -z "$TICKET_DIR" ]; then
    echo "Error: Ticket not found: $TICKET_ID" >&2
    exit 1
fi

TICKET_FILE="$TICKETS_DIR/$TICKET_DIR/ticket.md"

if [ ! -f "$TICKET_FILE" ]; then
    echo "Error: ticket.md not found in $TICKET_DIR" >&2
    exit 1
fi

# Get current status
OLD_STATUS=$(grep -m1 '^status:' "$TICKET_FILE" | sed 's/status:[[:space:]]*//' | tr -d '"'"'")

if [ "$OLD_STATUS" = "$NEW_STATUS" ]; then
    echo "Ticket $TICKET_ID is already '$NEW_STATUS'"
    exit 0
fi

# Get today's date
TODAY=$(date +%Y-%m-%d)

# Create temp file
TEMP_FILE=$(mktemp)

# Process the file
IN_FRONTMATTER=0
FRONTMATTER_COUNT=0
STATUS_UPDATED=0
COMPLETED_HANDLED=0

while IFS= read -r line || [ -n "$line" ]; do
    # Track frontmatter boundaries
    if [ "$line" = "---" ]; then
        ((FRONTMATTER_COUNT++))
        if [ $FRONTMATTER_COUNT -eq 1 ]; then
            IN_FRONTMATTER=1
        elif [ $FRONTMATTER_COUNT -eq 2 ]; then
            IN_FRONTMATTER=0

            # If setting to done and completed not yet added, add it before closing ---
            if [ "$NEW_STATUS" = "done" ] && [ $COMPLETED_HANDLED -eq 0 ]; then
                echo "completed: $TODAY" >> "$TEMP_FILE"
            fi
        fi
        echo "$line" >> "$TEMP_FILE"
        continue
    fi

    if [ $IN_FRONTMATTER -eq 1 ]; then
        # Update status line
        if [[ "$line" =~ ^status: ]]; then
            echo "status: $NEW_STATUS" >> "$TEMP_FILE"
            STATUS_UPDATED=1
            continue
        fi

        # Handle completed field
        if [[ "$line" =~ ^completed: ]]; then
            if [ "$NEW_STATUS" = "done" ]; then
                # Update completed date
                echo "completed: $TODAY" >> "$TEMP_FILE"
                COMPLETED_HANDLED=1
            fi
            # If not done, skip this line (removes completed field)
            continue
        fi
    fi

    echo "$line" >> "$TEMP_FILE"
done < "$TICKET_FILE"

# Replace original file
mv "$TEMP_FILE" "$TICKET_FILE"

# Report
TITLE=$(grep -m1 '^title:' "$TICKET_FILE" | sed 's/title:[[:space:]]*//' | tr -d '"'"'")
echo "Updated: $TICKET_ID - $TITLE"
echo "Status:  $OLD_STATUS → $NEW_STATUS"
if [ "$NEW_STATUS" = "done" ]; then
    echo "Completed: $TODAY"
fi
