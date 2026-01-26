#!/bin/bash
# Search tickets by ID, title, description, or content
# Usage: find-tickets.sh /path/to/tickets "search query"
#
# Examples:
#   find-tickets.sh ./tickets "authentication"
#   find-tickets.sh ./tickets "005"
#   find-tickets.sh ./tickets "mock data"

TICKETS_DIR="$1"
QUERY="$2"

if [ -z "$TICKETS_DIR" ] || [ -z "$QUERY" ]; then
    echo "Usage: find-tickets.sh /path/to/tickets \"search query\"" >&2
    exit 1
fi

if [ ! -d "$TICKETS_DIR" ]; then
    echo "Error: Directory not found: $TICKETS_DIR" >&2
    exit 1
fi

echo "Search: \"$QUERY\""
echo ""
echo "RESULTS:"
echo "================================================================================"

FOUND=0

# Process each ticket directory
for dir in $(ls -1 "$TICKETS_DIR" | grep -E '^[0-9]{3}' | sort); do
    TICKET_FILE="$TICKETS_DIR/$dir/ticket.md"

    if [ ! -f "$TICKET_FILE" ]; then
        continue
    fi

    # Extract frontmatter fields
    ID=$(grep -m1 '^id:' "$TICKET_FILE" | sed 's/id:[[:space:]]*//' | tr -d '"'"'")
    TITLE=$(grep -m1 '^title:' "$TICKET_FILE" | sed 's/title:[[:space:]]*//' | tr -d '"'"'")
    DESCRIPTION=$(grep -m1 '^description:' "$TICKET_FILE" | sed 's/description:[[:space:]]*//' | tr -d '"'"'")
    STATUS=$(grep -m1 '^status:' "$TICKET_FILE" | sed 's/status:[[:space:]]*//' | tr -d '"'"'")

    # Check for matches (case-insensitive)
    MATCH_LOCATION=""

    # Check ID
    if echo "$ID" | grep -qi "$QUERY"; then
        MATCH_LOCATION="id"
    fi

    # Check title
    if echo "$TITLE" | grep -qi "$QUERY"; then
        if [ -n "$MATCH_LOCATION" ]; then
            MATCH_LOCATION="$MATCH_LOCATION, title"
        else
            MATCH_LOCATION="title"
        fi
    fi

    # Check description
    if echo "$DESCRIPTION" | grep -qi "$QUERY"; then
        if [ -n "$MATCH_LOCATION" ]; then
            MATCH_LOCATION="$MATCH_LOCATION, description"
        else
            MATCH_LOCATION="description"
        fi
    fi

    # Check content (body after frontmatter)
    CONTENT_MATCH=$(grep -i "$QUERY" "$TICKET_FILE" | grep -v "^id:" | grep -v "^title:" | grep -v "^description:" | head -1)
    if [ -n "$CONTENT_MATCH" ]; then
        if [ -n "$MATCH_LOCATION" ]; then
            MATCH_LOCATION="$MATCH_LOCATION, content"
        else
            MATCH_LOCATION="content"
        fi
    fi

    # If we found a match, display it
    if [ -n "$MATCH_LOCATION" ]; then
        ((FOUND++))
        echo ""
        printf "[%d] %s %s" "$FOUND" "$ID" "$TITLE"
        printf "%*s%s\n" $((60 - ${#ID} - ${#TITLE})) "" "$STATUS"

        # Truncate description if needed
        if [ ${#DESCRIPTION} -gt 70 ]; then
            DESCRIPTION="${DESCRIPTION:0:67}..."
        fi
        echo "    Description: $DESCRIPTION"
        echo "    Match: $MATCH_LOCATION"

        # Show content snippet if matched in content
        if [ -n "$CONTENT_MATCH" ]; then
            SNIPPET="${CONTENT_MATCH:0:60}"
            echo "    Snippet: ...${SNIPPET}..."
        fi
    fi
done

echo ""
echo "================================================================================"

if [ $FOUND -eq 0 ]; then
    echo "No tickets found matching \"$QUERY\""
else
    echo "Found $FOUND ticket(s)"
fi
