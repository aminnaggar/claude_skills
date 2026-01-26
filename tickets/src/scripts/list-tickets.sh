#!/bin/bash
# List all tickets with status
# Usage: list-tickets.sh /path/to/tickets [status_filter]
#
# Examples:
#   list-tickets.sh ./tickets           # List all tickets
#   list-tickets.sh ./tickets draft     # List only draft tickets
#   list-tickets.sh ./tickets todo      # List only todo tickets
#   list-tickets.sh ./tickets current   # List only current tickets
#   list-tickets.sh ./tickets done      # List only done tickets
#   list-tickets.sh ./tickets open      # List draft + todo + current (not done)
#   list-tickets.sh ./tickets closed    # List done tickets (alias)

TICKETS_DIR="$1"
STATUS_FILTER="$2"

if [ -z "$TICKETS_DIR" ]; then
    echo "Usage: list-tickets.sh /path/to/tickets [status_filter]" >&2
    exit 1
fi

if [ ! -d "$TICKETS_DIR" ]; then
    echo "Error: Directory not found: $TICKETS_DIR" >&2
    exit 1
fi

# Counters
DRAFT_COUNT=0
TODO_COUNT=0
CURRENT_COUNT=0
DONE_COUNT=0

# Output header
printf "%-6s %-50s %-10s %s\n" "ID" "TITLE" "STATUS" "CREATED"
printf "%s\n" "================================================================================"

# Process each ticket directory
for dir in $(ls -1 "$TICKETS_DIR" | grep -E '^[0-9]{3}' | sort); do
    TICKET_FILE="$TICKETS_DIR/$dir/ticket.md"

    if [ ! -f "$TICKET_FILE" ]; then
        continue
    fi

    # Extract frontmatter fields using grep/sed
    ID=$(grep -m1 '^id:' "$TICKET_FILE" | sed 's/id:[[:space:]]*//' | tr -d '"'"'")
    TITLE=$(grep -m1 '^title:' "$TICKET_FILE" | sed 's/title:[[:space:]]*//' | tr -d '"'"'")
    STATUS=$(grep -m1 '^status:' "$TICKET_FILE" | sed 's/status:[[:space:]]*//' | tr -d '"'"'")
    CREATED=$(grep -m1 '^created:' "$TICKET_FILE" | sed 's/created:[[:space:]]*//' | tr -d '"'"'")
    PARENT=$(grep -m1 '^parent:' "$TICKET_FILE" | sed 's/parent:[[:space:]]*//' | tr -d '"'"'")

    # Update counters
    case "$STATUS" in
        draft) ((DRAFT_COUNT++)) ;;
        todo) ((TODO_COUNT++)) ;;
        current) ((CURRENT_COUNT++)) ;;
        done) ((DONE_COUNT++)) ;;
    esac

    # Apply filter if specified
    if [ -n "$STATUS_FILTER" ]; then
        case "$STATUS_FILTER" in
            open)
                # Show draft, todo, and current (not done)
                if [ "$STATUS" = "done" ]; then
                    continue
                fi
                ;;
            closed)
                # Show only done
                if [ "$STATUS" != "done" ]; then
                    continue
                fi
                ;;
            *)
                # Direct status match
                if [ "$STATUS" != "$STATUS_FILTER" ]; then
                    continue
                fi
                ;;
        esac
    fi

    # Determine if this is a sub-ticket (has a letter in ID)
    if [[ "$ID" =~ ^[0-9]+[a-z]$ ]]; then
        # Sub-ticket - indent
        DISPLAY_ID="  $ID"
    else
        DISPLAY_ID="$ID"
    fi

    # Truncate title if too long
    if [ ${#TITLE} -gt 48 ]; then
        TITLE="${TITLE:0:45}..."
    fi

    printf "%-6s %-50s %-10s %s\n" "$DISPLAY_ID" "$TITLE" "$STATUS" "$CREATED"
done

# Summary
printf "%s\n" "================================================================================"
TOTAL=$((DRAFT_COUNT + TODO_COUNT + CURRENT_COUNT + DONE_COUNT))
printf "Summary: %d draft | %d todo | %d current | %d done | %d total\n" "$DRAFT_COUNT" "$TODO_COUNT" "$CURRENT_COUNT" "$DONE_COUNT" "$TOTAL"
