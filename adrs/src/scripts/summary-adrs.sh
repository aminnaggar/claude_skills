#!/bin/bash
# Show id + summary for all active ADRs (for conflict detection)
# Usage: summary-adrs.sh /path/to/adrs

ADR_DIR="$1"

if [ -z "$ADR_DIR" ]; then
    echo "Usage: summary-adrs.sh /path/to/adrs" >&2
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

# Output header
printf "%-10s %-12s %s\n" "ID" "STATUS" "SUMMARY"
printf "%s\n" "================================================================================"

# Process each ADR file - only active (proposed + accepted)
for file in $(ls -1 "$ADR_DIR"/*.md 2>/dev/null | grep -E '/[0-9]{3}-' | sort); do
    [ ! -f "$file" ] && continue
    [[ "$file" == *"template"* ]] && continue

    FRONTMATTER=$(extract_frontmatter "$file")

    ID=$(yq -r '.id // ""' <<< "$FRONTMATTER" 2>/dev/null)
    STATUS=$(yq -r '.status // ""' <<< "$FRONTMATTER" 2>/dev/null)
    SUMMARY=$(yq -r '.summary // ""' <<< "$FRONTMATTER" 2>/dev/null)
    TITLE=$(yq -r '.title // ""' <<< "$FRONTMATTER" 2>/dev/null)

    [ -z "$ID" ] && continue

    # Only show active ADRs
    if [ "$STATUS" != "proposed" ] && [ "$STATUS" != "accepted" ]; then
        continue
    fi

    # Use title if no summary
    DISPLAY="${SUMMARY:-$TITLE}"

    printf "%-10s %-12s %s\n" "$ID" "$STATUS" "$DISPLAY"
done
