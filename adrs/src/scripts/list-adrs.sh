#!/bin/bash
# List ADRs with optional status filter
# Usage: list-adrs.sh /path/to/adrs [filter]
#
# Filters:
#   active     - proposed + accepted (default)
#   all        - all statuses
#   proposed   - only proposed
#   accepted   - only accepted
#   deprecated - only deprecated
#   superseded - only superseded

ADR_DIR="$1"
FILTER="${2:-active}"

if [ -z "$ADR_DIR" ]; then
    echo "Usage: list-adrs.sh /path/to/adrs [filter]" >&2
    exit 1
fi

if [ ! -d "$ADR_DIR" ]; then
    echo "Error: Directory not found: $ADR_DIR" >&2
    exit 1
fi

# Extract frontmatter from a file (first line must be ---, content until second ---)
extract_frontmatter() {
    awk '/^---$/{n++; if(n==2) exit; next} n==1{print}' "$1"
}

# Counters
PROPOSED_COUNT=0
ACCEPTED_COUNT=0
DEPRECATED_COUNT=0
SUPERSEDED_COUNT=0

# Output header
printf "%-10s %-50s %-12s %s\n" "ID" "TITLE" "STATUS" "DATE"
printf "%s\n" "================================================================================"

# Process each ADR file
for file in $(ls -1 "$ADR_DIR"/*.md 2>/dev/null | grep -E '/[0-9]{3}-' | sort); do
    # Skip if file doesn't exist or is template
    [ ! -f "$file" ] && continue
    [[ "$file" == *"template"* ]] && continue

    # Extract frontmatter and parse with yq
    FRONTMATTER=$(extract_frontmatter "$file")

    ID=$(yq -r '.id // ""' <<< "$FRONTMATTER" 2>/dev/null)
    TITLE=$(yq -r '.title // ""' <<< "$FRONTMATTER" 2>/dev/null)
    STATUS=$(yq -r '.status // ""' <<< "$FRONTMATTER" 2>/dev/null)
    DATE=$(yq -r '.date // ""' <<< "$FRONTMATTER" 2>/dev/null)

    # Skip if missing required fields
    [ -z "$ID" ] && continue

    # Update counters
    case "$STATUS" in
        proposed) ((PROPOSED_COUNT++)) ;;
        accepted) ((ACCEPTED_COUNT++)) ;;
        deprecated) ((DEPRECATED_COUNT++)) ;;
        superseded) ((SUPERSEDED_COUNT++)) ;;
    esac

    # Apply filter
    case "$FILTER" in
        active)
            if [ "$STATUS" != "proposed" ] && [ "$STATUS" != "accepted" ]; then
                continue
            fi
            ;;
        all)
            # Show everything
            ;;
        proposed|accepted|deprecated|superseded)
            if [ "$STATUS" != "$FILTER" ]; then
                continue
            fi
            ;;
        *)
            echo "Error: Unknown filter '$FILTER'. Use: active, all, proposed, accepted, deprecated, superseded" >&2
            exit 1
            ;;
    esac

    # Truncate title if too long
    if [ ${#TITLE} -gt 48 ]; then
        TITLE="${TITLE:0:45}..."
    fi

    printf "%-10s %-50s %-12s %s\n" "$ID" "$TITLE" "$STATUS" "$DATE"
done

# Summary
printf "%s\n" "================================================================================"
TOTAL=$((PROPOSED_COUNT + ACCEPTED_COUNT + DEPRECATED_COUNT + SUPERSEDED_COUNT))
printf "Summary: %d proposed | %d accepted | %d deprecated | %d superseded | %d total\n" \
    "$PROPOSED_COUNT" "$ACCEPTED_COUNT" "$DEPRECATED_COUNT" "$SUPERSEDED_COUNT" "$TOTAL"
